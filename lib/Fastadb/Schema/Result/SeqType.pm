package Fastadb::Schema::Result::SeqType;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('seq_type');

__PACKAGE__->add_columns(
	seq_type_id =>{
		accessor  => 'seq_type',
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	seq_type =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(seq_type_uniq => [qw/seq_type/]);

__PACKAGE__->set_primary_key('seq_type_id');

__PACKAGE__->has_many(seqs => 'Fastadb::Schema::Result::Seq', 'seq_type_id');

1;