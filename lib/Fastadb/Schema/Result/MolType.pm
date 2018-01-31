package Fastadb::Schema::Result::MolType;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('mol_type');

__PACKAGE__->add_columns(
	mol_type_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	type =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(mol_type_uniq => [qw/type/]);

__PACKAGE__->set_primary_key('mol_type_id');

__PACKAGE__->has_many(seqs => 'Fastadb::Schema::Result::Molecule', 'mol_type_id');

1;