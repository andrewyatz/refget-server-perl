package Fastadb::Schema::ResultSet::Release;

use strict;
use warnings;

use base qw/Fastadb::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'release';
}

sub key {
	my ($self) = @_;
	return 'release_uniq';
}

sub create_entry {
	my ($self, $release, $division, $species) = @_;
	my $obj = $self->find_or_create({$self->type() => $release, division => $division, species => $species}, {key => $self->key()});
	return $obj;
}

1;