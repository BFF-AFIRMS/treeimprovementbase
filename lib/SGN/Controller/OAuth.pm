package SGN::Controller::OAuth;
use Moose;
use URI::FromHash 'uri';
use namespace::autoclean;
use Data::Dumper;

use Try::Tiny;
use Crypt::JWT qw(decode_jwt);
use LWP::UserAgent;
use HTTP::Request;
use JSON::XS qw(decode_json); 

BEGIN {extends 'Catalyst::Controller'; }

our $LOGIN_COOKIE_NAME = 'sgn_session_id';

=head1 NAME

SGN::Controller::OAuth - SGN OAuth Controller

=head1 DESCRIPTION

SGN OAuth Controller. Implements OAuth protocol for login based on Authorization token.

=head2 oauth

Public path: /oauth/login

=cut

sub login : Path('/oauth/login') {
    my ( $self, $c ) = @_;

    # Validate and parse the authorization token
    my $public_keypath = '/data/certs/keycloak.key';
    my $public_keyurl = 'http://keycloak:9080/auth/realms/BFF-AFIRMS';
    my $token_url = 'http://keycloak:9080/auth/realms/BFF-AFIRMS/protocol/openid-connect/token';
    if (! -e $public_keypath) {
        download_public_key($public_keyurl, $public_keypath);
    }

    my $public_key = Crypt::PK::RSA->new($public_keypath);
    my $authorization = $c->request->env->{HTTP_AUTHORIZATION};
    my $token = $authorization =~ s/Bearer\s+//r;
    my $data;
    try {
        $data = decode_jwt(token => $token, key => $public_key);
    } catch {
        if (index($_, "exp claim check failed") != -1) {
            print "$_\n";
            print "$authorization\n";
            die $_;  # rethrow
        }
        else {
            die $_;  # rethrow
        }
    };

    # Log the user in
    my $login = CXGN::Login->new($c->dbc->dbh());
    my $username = $data->{preferred_username};
    my $first_name = $data->{given_name};
    my $last_name = $data->{family_name};
    my $email = $data->{email};
    my $login_info; #information about whether login succeeded, and if not, why not
	print STDERR "NOW LOGGING IN USER $username\n";

    my $schema = $c->dbic_schema("Bio::Chado::Schema");
    my $q = "SELECT sp_person_id, user_prefs FROM sgn_people.sp_person WHERE UPPER(username)=UPPER(?)";
    my $h = $schema->storage->dbh()->prepare($q);
    my $num_rows = $h->execute($username);
    my ($person_id, $user_prefs) = $h->fetchrow_array();

    my @fail = ();

    # Create new user
    if (! defined $person_id ) {
        print STDERR "Adding new account...\n";

        # breedbase specific requirements
        my @fail = ();
        if (length($username) < 7) {
            push @fail, "Username is too short. Username must be 7 or more characters";
        } elsif ( $username =~ /\s/ ) {
            push @fail, "Username must not contain spaces";
        }
        # generate random password
        my $password = join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..32;

        if (@fail) {
            $c->stash->{rest} = { error => "Account creation failed for the following reason(s): ".(join ", ", @fail) };
            return;
        }

        my $new_user = CXGN::People::Login->new($c->dbc->dbh());
        $new_user -> set_username($username);
        $new_user -> set_pending_email($email);
        $new_user -> store();

        # TBD get groups/roles

        print STDERR "Generated sp_person_id ".$new_user->get_sp_person_id()."\n";
        print STDERR "Update password...\n";
        $new_user->update_password($password);

        print STDERR "Store Person object...\n";
        $person_id=$new_user->get_sp_person_id();
        my $new_person=CXGN::People::Person->new($c->dbc->dbh(),$person_id);
        $new_person->set_first_name($first_name);
        $new_person->set_last_name($last_name);
        $new_person->store();

        $c->stash->{rest} = { message => "Account was created with username \"$username\"."};

    }  elsif ( $num_rows > 1 ) {
        push @fail, "Duplicate entries found for username '$username'";
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

    $c->stash->{data} = $data;
    $c->stash->{template} = '/oauth/login.mas';
}



sub download_public_key {
    my ($url, $file_path) = @_;
    my $agent = LWP::UserAgent->new();
    my $request = HTTP::Request->new('GET', $url);
    my $response = $agent->request($request);
    my $key_value = (decode_json $response->{_content})->{public_key};

    # save to file
    open(my $fh, '>', $file_path) or die "Could not open file '$file_path' $!";
    print $fh "-----BEGIN PUBLIC KEY-----\n" . $key_value . "\n-----END PUBLIC KEY-----\n";
    close $fh;
}

sub refresh_token {
    my ($url) = @_;
    my $agent = LWP::UserAgent->new();
    my $request = HTTP::Request->new('POST', $url);
}   

1;
