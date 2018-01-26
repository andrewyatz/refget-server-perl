package Fastadb::Schema::Abstract::Dict;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Carp qw/carp/;

sub type {
	my ($self) = @_;
	# return '';
	carp 'Subclass; key type unimplemented';
}

sub key {
	my ($self) = @_;
	# return '';
	carp 'Subclass; key type unimplemented';
}

sub create_entries {
	my ($self, $entries) = @_;
	my @ret;
	foreach my $value (@{$entries}) {
		push(@ret, $self->create_entry($value));
	}
	return \@ret;
}

sub create_entry {
	my ($self, $value) = @_;
	my $obj = $self->find_or_create({$self->type() => $value}, {key => $self->key()});
	return $obj;
}

1;