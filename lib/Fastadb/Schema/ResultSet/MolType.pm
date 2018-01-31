package Fastadb::Schema::ResultSet::MolType;

use strict;
use warnings;

use base qw/Fastadb::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'type';
}

sub key {
	my ($self) = @_;
	return 'mol_type_uniq';
}

1;