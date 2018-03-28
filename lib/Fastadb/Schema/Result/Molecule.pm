package Fastadb::Schema::Result::Molecule;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('molecule');

__PACKAGE__->add_columns(
	molecule_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
    is_numeric => 1,
	},
	seq_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
  },
	release_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
  },
	id =>{
		data_type => 'varchar',
    size => 128,
		is_nullable => 0,
	},
	first_seen  =>{
		data_type   => 'integer',
    is_boolean  => 1,
		false_is    => ['0','-1'],
		is_nullable => 0,
	},
	mol_type_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
	},
	version =>{
		data_type => 'integer',
		size      => 4,
		is_nullable => 1,
    is_numeric => 1,
	},
);

__PACKAGE__->add_unique_constraint(
  molecule_uniq => [qw/id mol_type_id/]
);

__PACKAGE__->set_primary_key('molecule_id');

__PACKAGE__->belongs_to(seq => 'Fastadb::Schema::Result::Seq', 'seq_id');
__PACKAGE__->belongs_to(release => 'Fastadb::Schema::Result::Release', 'release_id');
__PACKAGE__->belongs_to(mol_type => 'Fastadb::Schema::Result::MolType', 'mol_type_id');
__PACKAGE__->has_many(synonyms => 'Fastadb::Schema::Result::Synonym', 'molecule_id');

1;