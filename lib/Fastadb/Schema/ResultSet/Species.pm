package Fastadb::Schema::ResultSet::Species;

use strict;
use warnings;

use base qw/Fastadb::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'species';
}

sub key {
	my ($self) = @_;
	return 'species_uniq';
}

1;