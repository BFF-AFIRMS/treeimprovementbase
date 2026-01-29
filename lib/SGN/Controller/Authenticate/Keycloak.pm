package SGN::Controller::Authenticate::Keycloak;

use Moose;
use namespace::autoclean;

use Crypt::JWT qw(decode_jwt);
use Digest::SHA qw(sha256);
use HTTP::Request;
use MIME::Base64::URLSafe;
use LWP::UserAgent;
use JSON::XS qw(decode_json encode_json);
use URI qw( );
use Try::Tiny;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

our $LOGIN_COOKIE_NAME = 'sgn_session_id';

=head1 NAME

SGN::Controller::Authenticate::Keycloak - SGN Authenticate Keycloak Controller

=head1 DESCRIPTION

SGN Authenticate Keycloak Controller. Implements OIDC login protocol for Keycloak

=head2 start

Start the authentication flow by redirecting the user to the keycloak login page.

=cut

sub start : Path('/authenticate/keycloak/start') {
    my ( $self, $c ) = @_;

    # Read from config
    my $site_url = $c->get_conf('main_production_site_url');
    my $domain = URI->new($site_url)->host;

    my $keycloak              = $c->get_conf('OAuth')->{'keycloak'};
    my $frontend_url          = $keycloak->{frontend_url};
    my $client_id             = $keycloak->{client_id};
    my $code_challenge_method = $keycloak->{code_challenge_method} || 'plain';

    # generate code challenge (ex. random salt, base64 encoded for safe urls, + SHA256 hash )
    # this will be checked by the provider (keycloak) later, when we request an access token
    # to make sure the request legitimately came from us
    my $gen            = String::Random->new;
    my $code_verifier  = urlsafe_b64encode($gen->randpattern("s" x 40));
    my $code_challenge = $code_verifier;

    # check if the provider is expecting a PKCE SHA256 hash
    if ($code_challenge_method eq "S256") {
        $code_challenge = urlsafe_b64encode(sha256($code_verifier));
    }

    # generate state (ex. random salt, base64 encoded for safe urls )
    # this will be checked by us later, when we request an access token, to make sure that the
    # response legitimately came from keycloak
    my $state_verifier = urlsafe_b64encode($gen->randpattern("s" x 40));
    my $state          = urlsafe_b64encode(sha256($state_verifier));

    # Save the original verifiers as cookies, so we can look them up later in the callback function
    # TODO: There needs to be better way to save these (ex. sgn_people.sp_token), because using
    #       SameSite=Lax to send it back and forth to the provider defeats the security purpose.
    $c->response->cookies->{"keycloak_code_verifier"} = {
        value    => $code_verifier,
        domain   => $domain,
        path     => "/authenticate/keycloak",
        samesite => 'Lax',
        httponly => 1,
        secure   => 1,
        expires  => '+5m',
    };

    $c->response->cookies->{"keycloak_state_verifier"} = {
        value    => $state_verifier,
        domain   => $domain,
        path     => "/authenticate/keycloak",
        samesite => 'Lax',
        httponly => 1,
        secure   => 1,
        expires  => '+5m',
    };

    # Generate the login page url
    my $params = {
        client_id             => $client_id,
        redirect_uri          => "$site_url/authenticate/keycloak/callback",
        scope                 => 'openid email profile',
        response_type         => 'code',
        code_challenge        => $code_challenge,
        code_challenge_method => $code_challenge_method,
        state                 => $state,
    };
    my $auth_url = URI->new("$frontend_url/protocol/openid-connect/auth");
    $auth_url->query_form(%$params);

    # Redirect the user to the login page for authentication
    $c->res->redirect( $auth_url );
}


=head2 callback

After a successful authentication in the keycloak login page, redirects the
user back to this url, with the temporary authorization code available to
exchange for a full access token.

=cut

sub callback : Path('/authenticate/keycloak/callback') {
    my ( $self, $c ) = @_;

    $c->stash->{template} = '/authenticate/error_message.mas';

    # -------------------------------------------------------------------------
    # Read from config

    my $keycloak = $c->get_conf('OAuth')->{'keycloak'};

    my $frontend_url   = $keycloak->{frontend_url};
    my $client_id      = $keycloak->{client_id};
    my $client_secret  = $keycloak->{client_secret};
    my $backend_url    = $keycloak->{backend_url} || $frontend_url;
    my $auto_provision = $keycloak->{auto_provision} || 0;

    my $site_url = $c->get_conf('main_production_site_url');
    my $tempfiles_base = $c->get_conf('tempfiles_base');

    # -------------------------------------------------------------------------
    # Error handling and verification

    my $error = $c->req->param("error");
    my $error_description = "";

    if ($error) {
        $c->stash->{message} = "
        $error
        $error_description
        ";
        return
    }

    my $iss = $c->req->param("iss");
    if ($iss ne $frontend_url) {
        $c->stash->{message} = "
        The issuer received from the provider does not match the expected issuer.
        Expected issuer: $frontend_url
        Received issuer: $iss
        Please try to login again, or contact your system administrator for more help.
        ";
        return
    }

    my $code_verifier = $c->request->cookies->{keycloak_code_verifier};
    my $state_verifier = $c->request->cookies->{keycloak_state_verifier};
    if (! defined $code_verifier || ! defined $state_verifier ) {
        $c->stash->{message} = "
        The state and/or code verifiers could not be found.
        Please try to login again, or contact your system administrator for more help.
        ";
        return
    } else {
        $code_verifier = $code_verifier->value;
        $state_verifier = $state_verifier->value;
    }

	my $state_expected = urlsafe_b64encode(sha256($state_verifier));
	my $state_observed = $c->req->param("state");

    if ($state_expected ne $state_observed) {
        $c->stash->{message} = "
        The state returned by keycloak does not match the initiating state.
        Expected state: $state_expected
        Received state: $state_observed
        Please try to login again, or contact your system administrator for more help.
        ";
        return
    }

    # -------------------------------------------------------------------------
    # Exchange authorization code for access token

    my $token_url = URI->new("$backend_url/protocol/openid-connect/token");
    my %form;
    $form{'grant_type'}    = 'authorization_code';
    $form{'client_id'}     = $client_id;
    $form{'client_secret'} = $client_secret;
    $form{'code'}          = $c->req->param("code");
    $form{'code_verifier'} = $code_verifier;
    $form{'redirect_uri'}  = "$site_url/authenticate/keycloak/callback";

    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($token_url, \%form);
    my $content = decode_json $response->{_content};
    ($error, $error_description) = ($content->{error}, $content->{error_description});

    if ($error) {
        $c->stash->{message} = "
        $error
        $error_description
        ";
        return
    }

    my $access_token = $content->{access_token};
    my $refresh_token = $content->{refresh_token};

    # TBD: Check email verification status


    # Validate and parse the authorization token
    my $public_keypath = $tempfiles_base . '/keycloak.public.key';
    if (! -e $public_keypath) {
        download_public_key($backend_url, $public_keypath);
    }

    my $public_key = Crypt::PK::RSA->new($public_keypath);
    my $data;
    try {
        $data = decode_jwt(token => $access_token, key => $public_key);
    } catch {
        $c->stash->{message} = "
        Failed to verify the token signature from keycloak.
        Please try to login again, or contact your system administrator for more help.
        ";
        return;
    };

    my $username   = $data->{preferred_username};
    my $first_name = $data->{given_name};
    my $last_name  = $data->{family_name};
    my $email      = $data->{email};
    my $email_verified = $data->{email_verified};

    # -------------------------------------------------------------------------
    # Check if user exists in the system

    # Require match of private_email (set at user account creation)
    my $schema = $c->dbic_schema("Bio::Chado::Schema");
    my $q = "SELECT sp_person_id, user_prefs FROM sgn_people.sp_person WHERE UPPER(private_email)=UPPER(?)";
    my $h = $schema->storage->dbh()->prepare($q);
    my $num_rows = $h->execute($email);
    my ($person_id, $user_prefs) = $h->fetchrow_array();

    if ( $num_rows > 1 ) {
        $c->stash->{message} = "
        Multiple users were found to have the private email: '$email'.
        Please contact your system administrator for more help.
        ";
        return;
    }

    if (! defined $person_id ) {

        # Make extra sure that this email is not in a pending state for another account
        my $q = "SELECT username FROM sgn_people.sp_person WHERE UPPER(contact_email)=UPPER(?) OR UPPER(pending_email)=UPPER(?)";
        my $h = $schema->storage->dbh()->prepare($q);
        my $num_rows = $h->execute($email, $email);
        my ($other_username) = $h->fetchrow_array();
        if ( $num_rows > 0 ) {
            $c->stash->{message} = "
            The provided email '$email' is associated with a different user '$other_username'.
            Please contact your system administrator for more help.
            ";
            return;
        }

        # ---------------------------------------------------------------------
        # Option 1: Not auto-provision, raise error

        if (! $auto_provision) {
            $c->stash->{message} = "
            No user was found with the private email '$email'.
            Please contact your system administrator for more help.
            ";
            return;
        }

        # ---------------------------------------------------------------------
        # Option 2: Auto-provision new user

        # Check for mirror site status
        if ($c->config->{is_mirror}) {
	        $c->stash->{message} = "
            This site is a mirror site and does not support adding users.
            Please go to the main site to create an account.
            ";
	        return;
        }

        # breedbase specific requirements for username composition
        if (length($username) < 7) {
            $c->stash->{message} = "
            The username '$username' is too short.
            Username must be 7 or more characters
            ";
            return
        } elsif ( $username =~ /\s/ ) {
            $c->stash->{message} = "
            The username '$username' contains spaces.
            ";
            return
        }

        # generate random password
        my $gen = String::Random->new;
        $gen->set_pattern(p => [ 'A'..'Z', 'a'..'z', 0..9 ]);
        my $password  = $gen->randpattern("p" x 40);

        # Create new user
        my $new_user = CXGN::People::Login->new($c->dbc->dbh());
        $new_user->set_username($username);
        $new_user->set_password($password);
        $new_user->set_private_email($email);
        $new_user->store();

        # Create new person
        #this is being added because the person object still uses two different objects, despite the fact that we've merged the tables
        $person_id  = $new_user->get_sp_person_id();
        my $new_person = CXGN::People::Person->new($c->dbc->dbh(), $person_id);
        $new_person->set_first_name($first_name);
        $new_person->set_last_name($last_name);
        $new_person->store();
    }

    # ---------------------------------------------------------------------
    # Log the user in

    my $login = CXGN::Login->new($c->dbc->dbh());
    my $new_cookie_string = String::Random->new()->randpattern("c" x 71);

    CXGN::Cookie::set_cookie( $LOGIN_COOKIE_NAME, $new_cookie_string );
    CXGN::Cookie::set_cookie( "user_prefs", $user_prefs );

    my $sth   = $login->get_sql("login");
    $sth->execute( $new_cookie_string, $person_id );

    # Redirect to home page
    print STDERR "keycloak callback redirecting to: " . $c->req->base . "\n";
    $c->res->redirect( $c->req->base );
}


sub download_public_key {
    my ($url, $file_path) = @_;

    # download as json
    my $agent     = LWP::UserAgent->new();
    my $request   = HTTP::Request->new('GET', $url);
    my $response  = $agent->request($request);
    my $key_value = (decode_json $response->{_content})->{public_key};

    # save to file
    open(my $fh, '>', $file_path) or die "Could not open file '$file_path' $!";
    print $fh "-----BEGIN PUBLIC KEY-----\n" . $key_value . "\n-----END PUBLIC KEY-----\n";
    close $fh;
}

1;
