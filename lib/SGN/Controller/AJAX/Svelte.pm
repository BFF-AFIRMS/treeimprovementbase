
package SGN::Controller::AJAX::Svelte;

use Moose;
use JSON::Any;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );

sub get_user_roles :Path('/ajax/user/role') Args(0) {
    my $self = shift;
    my $c = shift;

    try {
        if (!$c->user){die "Not logged in.\n";}
        my $user_role = $c->user->get_object()->get_user_type();
        $c->stash->{rest} = { "user_role" => $user_role };
    } catch {
        $c->stash->{rest} = { error => $_};
    };
}

1;
