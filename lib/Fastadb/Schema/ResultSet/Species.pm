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

sub create_entry {
	my ($self, $species, $assembly) = @_;
	my $obj = $self->find_or_create({$self->type() => $species, assembly => $assembly}, {key => $self->key()});
	return $obj;
}

1;