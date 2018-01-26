package Fastadb::Schema::Result::Species;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('species');

__PACKAGE__->add_columns(
	species_id =>{
		accessor  => 'species',
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
    is_numeric => 1,
	},
	species =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
  },
);

__PACKAGE__->add_unique_constraint(
  species_uniq => [qw/species/]
);

__PACKAGE__->set_primary_key('species_id');

__PACKAGE__->has_many(release => 'Fastadb::Schema::Result::Release', 'species_id');

1;