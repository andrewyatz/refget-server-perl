package Fastadb::Schema::Result::Division;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('division');

__PACKAGE__->add_columns(
	division_id =>{
		accessor  => 'division',
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	division =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(division_uniq => [qw/division/]);

__PACKAGE__->set_primary_key('division_id');

__PACKAGE__->has_many(release => 'Fastadb::Schema::Result::Release', 'division_id');

1;