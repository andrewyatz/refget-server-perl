package Fastadb::Schema::Result::Synonym;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('synonym');

__PACKAGE__->add_columns(
	synonym_id =>{
		accessor  => 'synonym',
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	molecule_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
	},
	synonym =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(synonym_uniq => [qw/molecule_id synonym/]);

__PACKAGE__->set_primary_key('synonym_id');

__PACKAGE__->belongs_to(molecule => 'Fastadb::Schema::Result::Molecule', 'molecule_id');

1;