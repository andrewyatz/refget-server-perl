package Fastadb::Exe::DefaultDicts;

use strict;
use warnings;

use Moose;

has 'schema'    => ( isa => 'Fastadb::Schema', is => 'ro', required => 1 );
has 'divisions' => ( isa => 'ArrayRef[Str]', is => 'ro', builder => 'build_default_divisions' );
has 'mol_types' => ( isa => 'ArrayRef[Str]', is => 'ro', builder => 'build_default_mol_types' );

sub run {
  my($self) = @_;
  my $return = {};
  $return->{divisions} = $self->populate_dict('Division', $self->divisions());
  $return->{mol_type} =$self->populate_dict('MolType', $self->mol_types());
  return $return;
}

sub build_default_divisions {
  my ($self) = @_;
  return [qw/
    ensembl
    plants
    protists
    bacteria
    metazoa
    fungi
  /];
}

sub build_default_mol_types {
  my ($self) = @_;
  return [qw/
	  protein
    cds
    cdna
    ncrna
    dna
  /];
}

sub populate_dict {
  my ($self, $resultset, $values) = @_;
  my @objs = @{$self->schema->resultset($resultset)->create_entries($values)};
  return \@objs;
}

__PACKAGE__->meta->make_immutable;

1;