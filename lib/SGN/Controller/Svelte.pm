package SGN::Controller::Svelte;

use Moose;

BEGIN { extends 'Catalyst::Controller' };

sub people_search : Path('/svelte/breeders/manage_programs') Args(0) {
    my $self = shift;
    my $c = shift;
    $c->stash->{template} = '/svelte/breeders/manage_programs.html';
}

1;
