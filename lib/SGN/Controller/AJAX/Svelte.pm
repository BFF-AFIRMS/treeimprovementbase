
package SGN::Controller::AJAX::Svelte;

use Data::Dumper;
use Moose;
use JSON::Any;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );

sub get_breeding_programs :Path('/ajax/svelte/breeding_programs') Args(0) {
    my $self = shift;
    my $c = shift;

    try {
        if (!$c->user){die "Not logged in.\n";}
        my $schema = $c->dbic_schema("Bio::Chado::Schema");
        my $q = "
        select project_id, name, description
        from project
        left join projectprop using (project_id)
        where projectprop.type_id=(select cvterm_id from cvterm where name = 'breeding_program');";
        my $h = $schema->storage->dbh()->prepare($q);
        $h->execute();

        my @breeding_programs;
        while (my ($project_id, $name, $description) = $h->fetchrow_array()){
            my $record = {
                project_id => $project_id,
                name => $name,
                description => $description,
            };;
            push (@breeding_programs, $record);
        }
        $c->stash->{rest} = { breeding_programs => \@breeding_programs};

    } catch {
        $c->stash->{rest} = { error => $_};
    };
}

sub get_organisms :Path('/ajax/svelte/organisms') Args(0) {
    my $self = shift;
    my $c = shift;

    try {
        my $schema = $c->dbic_schema("Bio::Chado::Schema");
        my $q = "select organism_id, common_name, abbreviation, genus, species from public.organism";
        my $h = $schema->storage->dbh()->prepare($q);
        $h->execute();

        my @organisms;
        while (my ($organism_id, $common_name, $abbreviation, $genus, $species) = $h->fetchrow_array()){
            my $record = {
                organism_id => $organism_id,
                common_name => $common_name,
                abbreviation => $abbreviation,
                genus => $genus,
                species => $species,
            };;
            push (@organisms, $record);
        }
        $c->stash->{rest} = { organisms => \@organisms};
    } catch {
        $c->stash->{rest} = { error => $_};
    };
}

sub get_user_role :Path('/ajax/user/role') Args(0) {
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
