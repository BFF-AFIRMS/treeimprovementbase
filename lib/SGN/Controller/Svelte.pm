package SGN::Controller::Svelte;

use Moose;

BEGIN { extends 'Catalyst::Controller' };

sub breeding_programs : Path('/svelte/breeders/manage_programs') Args(0) {
    my $self = shift;
    my $c = shift;
    $c->stash->{template} = '/svelte/breeders/manage_programs.html';
}

sub people_search : Path('/svelte/search/organisms') Args(0) {
    my $self = shift;
    my $c = shift;
    $c->stash->{template} = '/svelte/search/organisms.html';
}

1;
