
package SGN::Controller::AJAX::Search::Organism;

use Moose;
use JSON::Any;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }


__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );

sub search :Path('/ajax/search/organism') Args(0) {
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
            last;
        }
        $c->stash->{rest} = { organisms => \@organisms};
    } catch {
        $c->stash->{rest} = { error => $_};
    };
}

1;
