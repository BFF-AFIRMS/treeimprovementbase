package SGN::Controller::Authenticate::Google;

use Moose;
use namespace::autoclean;

use Crypt::JWT qw(decode_jwt);
use Digest::SHA qw(sha256);
use HTTP::Request;
use MIME::Base64 qw(decode_base64);
use MIME::Base64::URLSafe;
use LWP::UserAgent;
use JSON::XS qw(decode_json encode_json);
use URI qw( );
use Try::Tiny;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

our $LOGIN_COOKIE_NAME = 'sgn_session_id';

=head1 NAME

SGN::Controller::Authenticate::Google - SGN Authenticate Google Controller

=head1 DESCRIPTION

SGN Authenticate Google Controller. Implements OIDC login protocol for Google

=head2 start

Start the authentication flow by redirecting the user to the google login page.

=cut

sub start : Path('/authenticate/google/start') {
    my ( $self, $c ) = @_;

    # Read from config
    my $site_url = $c->get_conf('main_production_site_url');
    my $domain = URI->new($site_url)->host;

    my $google        = $c->get_conf('OAuth')->{'google'};
    my $frontend_url  = "https://accounts.google.com/o/oauth2/v2/auth";
    my $client_id     = $google->{client_id};
    my $client_secret = $google->{client_secret};

    # generate state (ex. random salt, base64 encoded for safe urls )
    # this will be checked by us later, when we request an access token, to make sure that the
    # response legitimately came from google
    my $gen            = String::Random->new;
    my $state_verifier = urlsafe_b64encode($gen->randpattern("s" x 40));
    my $state          = urlsafe_b64encode(sha256($state_verifier));

    my $nonce_verifier = urlsafe_b64encode($gen->randpattern("s" x 40));
	my $nonce = urlsafe_b64encode(sha256($nonce_verifier));

    # Save the original code verifiers as cookies, so we can look it up on the callback endpoint
	# TBD: Figure out the SameSite setting
    $c->response->cookies->{"google_state_verifier"} = {
        value    => $state_verifier,
        domain   => $domain,
        path     => "/authenticate/google",
        samesite => 'Lax',
        httponly => 1,
        secure   => 1,
        expires  => '+5m',
    };

    $c->response->cookies->{"google_nonce_verifier"} = {
        value    => $state_verifier,
        domain   => $domain,
        path     => "/authenticate/google",
        samesite => 'Lax',
        httponly => 1,
        secure   => 1,
        expires  => '+5m',
    };

    # Generate the login page url
    my $params = {
        client_id     => $client_id,
        redirect_uri  => "$site_url/authenticate/google/callback",
        scope         => 'openid email profile',
        response_type => 'code',
		state         => $state,
		nonce         => $nonce,
    };

    my $auth_url = URI->new($frontend_url);
    $auth_url->query_form(%$params);

    # Redirect the user to the login page for authentication
    $c->res->redirect( $auth_url );
}


=head2 callback

After a successful authentication in the google login page, redirects the
user back to this url, with the temporary authorization code available to
exchange for a full access token.

=cut

sub callback : Path('/authenticate/google/callback') {
    my ( $self, $c ) = @_;

    $c->stash->{template} = '/authenticate/error_message.mas';

    # -------------------------------------------------------------------------
    # Read from config

    my $google = $c->get_conf('OAuth')->{'google'};

    my $frontend_url   = "https://accounts.google.com/o/oauth2/v2/auth";
    my $client_id      = $google->{client_id};
    my $client_secret  = $google->{client_secret};
    my $auto_provision = $google->{auto_provision} || 0;

    my $site_url = $c->get_conf('main_production_site_url');
    my $tempfiles_base = $c->get_conf('tempfiles_base');

    my $status;
    my %result;

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

    my $state_verifier = $c->request->cookies->{google_state_verifier};
    if (! defined $state_verifier ) {
        $c->stash->{message} = "
        The state and/or code verifiers could not be found.
        Please try to login again, or contact your system administrator for more help.
        ";
        return
    } else {
        $state_verifier = $state_verifier->value;
    }

	my $state_expected = urlsafe_b64encode(sha256($state_verifier));
	my $state_observed = $c->req->param("state");

    if ($state_expected ne $state_observed) {
        $c->stash->{message} = "
        The state returned by google does not match the initiating state.
        Expected state: $state_expected
        Received state: $state_observed
        Please try to login again, or contact your system administrator for more help.
        ";
        return
    }

    # -------------------------------------------------------------------------
    # Exchange authorization code for access token

    my $token_url = URI->new("https://oauth2.googleapis.com/token");
    my %form;
    $form{'grant_type'}    = 'authorization_code';
    $form{'client_id'}     = $client_id;
    $form{'client_secret'} = $client_secret;
    $form{'code'}          = $c->req->param("code");
    $form{'redirect_uri'}  = "$site_url/authenticate/google/callback";

    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($token_url, \%form);
    my $content = decode_json $response->{_content};
    ($error, $error_description) = ($content->{error}, $content->{error_description});

    if ($error) {
        $c->stash->{message} = "
        $error: $error_description
        ";
        return
    }

    my $access_token = $content->{access_token};
    # TODO: Validate and parse the authorization token

    # userinfo
    my $userinfo_url = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json";
    my $request   = HTTP::Request->new('GET', $userinfo_url);
    $request->header( "Authorization" => "Bearer $access_token" );
    $response  = $ua->request($request);

    $content = decode_json $response->{_content};
    ($error, $error_description) = ($content->{error}, $content->{error_description});

    if ($error) {
        $c->stash->{message} = "
        $error: $error_description
        ";
        return
    }

    my $data = $content;
    #print STDERR "data: " . Dumper($data) . "\n";

    # my $public_keypath = $tempfiles_base . '/google.public.key';
    # if (! -e $public_keypath) {
    #     download_public_cert($backend_url, $public_keypath);
    # }

    # my $public_key = Crypt::PK::RSA->new($public_keypath);
    # my $data;
    # try {
    #     $data = decode_jwt(token => $access_token, key => $public_key);
    # } catch {
    #     $c->stash->{message} = "
    #     Failed to verify the token signature from google.
    #     Please try to login again, or contact your system administrator for more help.
    #     ";
    #     return;
    # };

    my $first_name = $data->{given_name};
    my $last_name  = $data->{family_name};
    my $email      = $data->{email};
    my $email_verified = $data->{verified_email};

    my @email_split = split(/@/, $email);
    my $username = $email_split[0];

    # TODO: Check email verified

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
    my $test = $sth->execute( $new_cookie_string, $person_id );
    print STDERR "person_id: $person_id, cookie_string: $new_cookie_string\n";
    print STDERR "test: " . Dumper($test) . "\n";

    # Redirect to home page
    print STDERR "google callback redirecting to: " . $c->req->base . "\n";
    $c->res->redirect( $c->req->base );
}

sub download_public_cert {
    my ($kid, $file_path) = @_;

    my $url = "https://www.googleapis.com/oauth2/v3/certs";

    # download as json
    my $agent     = LWP::UserAgent->new();
    my $request   = HTTP::Request->new('GET', $url);
    my $response  = $agent->request($request);

    my $keys = (decode_json $response->{_content})->{keys};
    #print STDERR "keys: " . Dumper($keys) . "\n";

    # my $key_value = (decode_json $response->{_content})->{public_key};

    # # save to file
    # open(my $fh, '>', $file_path) or die "Could not open file '$file_path' $!";
    # print $fh "-----BEGIN PUBLIC KEY-----\n" . $key_value . "\n-----END PUBLIC KEY-----\n";
    # close $fh;
}

1;
