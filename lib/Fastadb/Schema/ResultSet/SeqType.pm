package Fastadb::Schema::ResultSet::SeqType;

use strict;
use warnings;

use base qw/Fastadb::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'seq_type';
}

sub key {
	my ($self) = @_;
	return 'seq_type_uniq';
}

1;