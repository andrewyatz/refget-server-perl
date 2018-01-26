package Fastadb::Schema::ResultSet::Division;

use strict;
use warnings;

use base qw/Fastadb::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'division';
}

sub key {
	my ($self) = @_;
	return 'division_uniq';
}

1;