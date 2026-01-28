package SGN::Controller::AJAX::Authenticate::Keycloak;

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

BEGIN {extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
);

our $LOGIN_COOKIE_NAME = 'sgn_session_id';

=head1 NAME

SGN::Controller::AJAX::Authenticate::Keycloak - SGN Authenticate Keycloak Controller

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

    my $keycloak = $c->get_conf('OAuth')->{'keycloak'};
    my $provider = $keycloak->{frontend_url};
    my $client_id = $keycloak->{client_id};
    my $code_challenge_method = $keycloak->{code_challenge_method} || 'plain';

    # generate code challenge (ex. random salt, base64 encoded for safe urls, + SHA256 hash )
    my $gen = String::Random->new;
    my $code_verifier = urlsafe_b64encode($gen->randpattern("ssssssssssssssssssssssssssssssssssssssss"));
    my $code_challenge = $code_verifier;

    # check if the provider is expecting a PKCE SHA256 hash
    if ($code_challenge_method eq "S256") {
        $code_challenge = urlsafe_b64encode(sha256($code_verifier));
    }

    my $state_verifier = urlsafe_b64encode($gen->randpattern("ssssssssssssssssssssssssssssssssssssssss"));
    my $state = urlsafe_b64encode(sha256($state_verifier));

    # Save the original code verifier as a cookie, so we can look it up on the callback endpoint
    # TBD: Samesite
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

    # Generate the authorization url
    my $params = {
        client_id             => $client_id,
        redirect_uri          => "$site_url/authenticate/keycloak/callback",
        scope                 => 'openid email profile',
        response_type         => 'code',
        code_challenge        => $code_challenge,
        code_challenge_method => $code_challenge_method,
        state                 => $state,
    };
    my $auth_url = URI->new("$provider/protocol/openid-connect/auth");
    $auth_url->query_form(%$params);

    $c->res->redirect( $auth_url );
}


=head2 callback

After a successful authentication in the keycloak login page, redirects the
user back to this url, with the temporary authorization code available to
exchange for a full access token.

=cut

sub callback : Path('/authenticate/keycloak/callback') {
    my ( $self, $c ) = @_;

    # -------------------------------------------------------------------------
    # Read from config

    my $keycloak = $c->get_conf('OAuth')->{'keycloak'};

    my $provider         = $keycloak->{frontend_url};
    my $provider_backend = $keycloak->{backend_url};
    my $client_id        = $keycloak->{client_id};
    my $client_secret    = $keycloak->{client_secret};

    my $site_url = $c->get_conf('main_production_site_url');

    my $status;
    my %result;

    # -------------------------------------------------------------------------
    # Error handling and verification

    my $error = $c->req->param("error");
    my $error_description = "";

    if ($error) {
        %result = (error=>"$error: $error_description");
        $c->stash->{rest} = \%result;
        return
    }

    my $iss = $c->req->param("iss");
    if ($iss ne $provider) {
        %result = (error=>"issuer does not match the provider");
        $c->stash->{rest} = \%result;
        return
    }

    my $code_verifier = $c->request->cookies->{keycloak_code_verifier};
    if (! defined $code_verifier) {
        # redirect back to login endpoint to get fresh cookie
        $c->res->redirect( "/authenticate/keycloak/start");
    } else {
        $code_verifier = $code_verifier->value;
    }

    my $state_verifier = $c->request->cookies->{keycloak_state_verifier};
    if (! defined $state_verifier) {
        # redirect back to login endpoint to get fresh cookie
        $c->res->redirect( "/authenticate/keycloak/start");
    } else {
        $state_verifier = $state_verifier->value;
    }

	my $state_expected = urlsafe_b64encode(sha256($state_verifier));
	my $state_observed = $c->req->param("state");

    if ($state_expected ne $state_observed) {
        %result = (error=>"Potential Cross-Site Request Forgery: state returned by keycloak does not match the initiating state.");
        $c->stash->{rest} = \%result;
        return
    }

    # -------------------------------------------------------------------------
    # Exchange authorization code for access token

    my $ua = LWP::UserAgent->new();
    my $token_url = URI->new("$provider_backend/protocol/openid-connect/token");
    my %form;
    $form{'grant_type'}    = 'authorization_code';
    $form{'client_id'}     = $client_id;
    $form{'client_secret'} = $client_secret;
    $form{'code'}          = $c->req->param("code");
    $form{'code_verifier'} = $code_verifier;
    $form{'redirect_uri'}  = "$site_url/authenticate/keycloak/callback";

    my $response = $ua->post($token_url, \%form);
    my $content = decode_json $response->{_content};
    ($error, $error_description) = ($content->{error}, $content->{error_description});

    if ($error) {
        %result = (error=>"$error: $error_description");
        $c->stash->{rest} = \%result;
        return
    }

    my $access_token = $content->{access_token};
    my $refresh_token = $content->{refresh_token};

    # Validate and parse the authorization token
    my $public_keypath = '/data/certs/keycloak.key';
    if (! -e $public_keypath) {
        download_public_key($provider_backend, $public_keypath);
    }

    my $public_key = Crypt::PK::RSA->new($public_keypath);
    my $data;
    try {
        $data = decode_jwt(token => $access_token, key => $public_key);
    } catch {
        # if (index($_, "exp claim check failed") != -1) {
        #     print "$_\n";
        #     die $_;  # rethrow
        # }
        %result = (error=>"$_");
        $c->stash->{rest} = \%result;
        return
    };

    # TBD: Check email verification

    # Log the user in
    my $login = CXGN::Login->new($c->dbc->dbh());
    my $username = $data->{preferred_username};
    my $first_name = $data->{given_name};
    my $last_name = $data->{family_name};
    my $email = $data->{email};
    my $login_info; #information about whether login succeeded, and if not, why not
	print STDERR "NOW LOGGING IN USER $username\n";

    # Require match of both username and email?
    my $schema = $c->dbic_schema("Bio::Chado::Schema");
    my $q = "SELECT sp_person_id, user_prefs FROM sgn_people.sp_person WHERE UPPER(username)=UPPER(?) AND UPPER(contact_email)=UPPER(?)";
    my $h = $schema->storage->dbh()->prepare($q);
    my $num_rows = $h->execute($username, $email);
    my ($person_id, $user_prefs) = $h->fetchrow_array();

    my @fail = ();

    # Create new user
    if (! defined $person_id ) {
        # Option 1: Raise error
        push @fail, "No user was found with the contact email $email";
        $c->stash->{rest} = { error => "Login failed for the following reason(s): ".(join ", ", @fail) };
        return;

        # Option 2: Auto-provision

        # print STDERR "Adding new account...\n";

        # # breedbase specific requirements
        # my @fail = ();
        # if (length($username) < 7) {
        #     push @fail, "Username is too short. Username must be 7 or more characters";
        # } elsif ( $username =~ /\s/ ) {
        #     push @fail, "Username must not contain spaces";
        # }
        # # generate random password
        # my $password = join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..32;

        # if (@fail) {
        #     $c->stash->{rest} = { error => "Account creation failed for the following reason(s): ".(join ", ", @fail) };
        #     return;
        # }

        # my $new_user = CXGN::People::Login->new($c->dbc->dbh());
        # $new_user -> set_username($username);
        # $new_user -> set_pending_email($email);
        # $new_user -> store();

        # # TBD get groups/roles

        # print STDERR "Generated sp_person_id ".$new_user->get_sp_person_id()."\n";
        # print STDERR "Update password...\n";
        # $new_user->update_password($password);

        # print STDERR "Store Person object...\n";
        # $person_id=$new_user->get_sp_person_id();
        # my $new_person=CXGN::People::Person->new($c->dbc->dbh(),$person_id);
        # $new_person->set_first_name($first_name);
        # $new_person->set_last_name($last_name);
        # $new_person->store();

        # $c->stash->{rest} = { message => "Account was created with username \"$username\"."};

    }

    if ( $num_rows > 1 ) {
        push @fail, "Duplicate entries found for contact email $email";
        $c->stash->{rest} = { error => "Account creation failed for the following reason(s): ".(join ", ", @fail) };
        return;
    }


    print STDERR "FOUND: $person_id\n";

    $login_info->{user_prefs} = $user_prefs;
    my $new_cookie_string = String::Random->new()->randpattern("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc");
    print STDERR "cookie: $new_cookie_string\n";

    # Complete login
    my $sth = $login->get_sql("login");
    $sth->execute( $new_cookie_string, $person_id );

    CXGN::Cookie::set_cookie( $LOGIN_COOKIE_NAME, $new_cookie_string );
    CXGN::Cookie::set_cookie( "user_prefs", $user_prefs );

    $login_info->{person_id}     = $person_id;
    $login_info->{first_name}    = $first_name;
    $login_info->{last_name}     = $last_name;
    $login_info->{cookie_string} = $new_cookie_string;

    # Redirect to home page
    $c->res->redirect( $c->req->base );
}


sub download_public_key {
    my ($url, $file_path) = @_;

    my $public_keypath = '/data/certs/keycloak.key';
    my $public_keyurl = 'http://keycloak:9080/auth/realms/BFF-AFIRMS';
    if (! -e $public_keypath) {
        # download as json
        my $agent = LWP::UserAgent->new();
        my $request = HTTP::Request->new('GET', $public_keyurl);
        my $response = $agent->request($request);
        my $key_value = (decode_json $response->{_content})->{public_key};

        # save to file
        open(my $fh, '>', $public_keypath) or die "Could not open file '$public_keypath' $!";
        print $fh "-----BEGIN PUBLIC KEY-----\n" . $key_value . "\n-----END PUBLIC KEY-----\n";
        close $fh;
    }
}

1;
