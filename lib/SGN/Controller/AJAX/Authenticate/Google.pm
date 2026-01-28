package SGN::Controller::AJAX::Authenticate::Google;

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

sub start : Path('/authenticate/google/start') {
    my ( $self, $c ) = @_;

    # Read from config
    my $site_url = $c->get_conf('main_production_site_url');
	my $domain = URI->new($site_url)->host;
    my $google = $c->get_conf('OAuth')->{'google'};
    my $client_id = $google->{client_id};

    # generate state (ex. random salt, base64 encoded for safe urls, + SHA256 hash )
    my $gen = String::Random->new;
    my $state_verifier = urlsafe_b64encode($gen->randpattern("ssssssssssssssssssssssssssssssssssssssss"));
	my $state = urlsafe_b64encode(sha256($state_verifier));

    my $gen = String::Random->new;
    my $nonce_verifier = urlsafe_b64encode($gen->randpattern("ssssssssssssssssssssssssssssssssssssssss"));
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
        value    => $nonce_verifier,
        domain   => $domain,
        path     => "/authenticate/google",
        samesite => 'Lax',
        httponly => 1,
        secure   => 1,
        expires  => '+5m',
    };	

    # Generate the authorization url
    my $params = {
        client_id             => $client_id,
        redirect_uri          => "$site_url/authenticate/google/callback",
        scope                 => 'openid email',
        response_type         => 'code',
		state                 => $state,
		nonce                 => $nonce,
    };

    my $auth_url = URI->new("https://accounts.google.com/o/oauth2/v2/auth");
    $auth_url->query_form(%$params);
    $c->res->redirect( $auth_url );
}


=head2 callback

After a successful authentication in the google login page, redirects the 
user back to this url, with the temporary authorization code available to 
exchange for a full access token.

=cut

sub callback : Path('/authenticate/google/callback') {
    my ( $self, $c ) = @_;

    # -------------------------------------------------------------------------
    # Read from config

    my $google = $c->get_conf('OAuth')->{'google'};
    my $client_id        = $google->{client_id};
    my $client_secret    = $google->{client_secret};

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

    my $state_verifier = $c->request->cookies->{google_state_verifier};
    if (! defined $state_verifier) {
        # redirect back to login endpoint to get fresh cookie
        $c->res->redirect( "/authenticate/google/start");
    } else {
        $state_verifier = $state_verifier->value;
    }

	my $state_expected = urlsafe_b64encode(sha256($state_verifier));
	my $state_observed = $c->req->param("state");

    if ($state_expected ne $state_observed) {
        %result = (error=>"Potential Cross-Site Request Forgery: state returned by google does not match the initiating state.");
        $c->stash->{rest} = \%result;
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
        %result = (error=>"$error: $error_description");
        $c->stash->{rest} = \%result;
        return
    }

    my $id_token = $content->{id_token};
	my @pieces = split(/\./, $id_token);
	my $data = decode_json (decode_base64 ${pieces[1]});

	# TBD: Check email verification
	print STDERR "data: " . Dumper($data) . "\n";
	

# Log the user in
    my $login = CXGN::Login->new($c->dbc->dbh());
    my $email = $data->{email};
    my $login_info; #information about whether login succeeded, and if not, why not
	print STDERR "NOW LOGGING IN USER with email $email\n";

    # Require match of email
    my $schema = $c->dbic_schema("Bio::Chado::Schema");
    my $q = "SELECT sp_person_id, user_prefs, first_name, last_name FROM sgn_people.sp_person WHERE UPPER(contact_email)=UPPER(?)";
    my $h = $schema->storage->dbh()->prepare($q);
    my $num_rows = $h->execute($email);
    my ($person_id, $user_prefs, $first_name, $last_name) = $h->fetchrow_array();

    my @fail = ();

    # Create new user
    if (! defined $person_id ) {
        # Option 1: Raise error
        push @fail, "No user was found with the contact email $email";
        $c->stash->{rest} = { error => "Login failed for the following reason(s): ".(join ", ", @fail) };
        return;
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
    $c->res->redirect( $c->req->base . "/about");
}


1;