package Fastadb::Exe::Import;

use strict;
use warnings;

use Moose;
use Carp qw/confess/;

has 'schema'    => ( isa => 'Fastadb::Schema', is => 'ro', required => 1 );
has 'fasta'     => ( isa => 'Fastadb::Fmt::Fasta', is => 'ro', required => 1 );
has 'species'   => ( isa => 'Str', is => 'ro', required => 1 );
has 'division'  => ( isa => 'Str', is => 'ro', required => 1 );
has 'release'   => ( isa => 'Int', is => 'ro', required => 1 );
has 'assembly'  => ( isa => 'Str', is => 'ro', required => 1 );

sub run {
  my ($self) = @_;
  my $fasta = $self->fasta();
  my ($species, $division, $release, $mol_type);

  $self->schema->txn_do(sub {
    $species = $self->schema->resultset('Species')->create_entry($self->species(), $self->assembly());
    $division = $self->schema->resultset('Division')->create_entry($self->division());
    $release = $self->schema->resultset('Release')->create_entry($self->release(), $division, $species);
    $mol_type = $self->schema->resultset('MolType')->find_entry($self->fasta()->type());
  });
  if(! defined $mol_type) {
    confess('No molecule_type in the database found for '.$self->fasta()->type());
  }

  my $rs = $self->schema->resultset('Seq');
  while(my $seq = $fasta->iterate()) {
    $self->schema->txn_do(sub {
      $rs->create_seq($seq, $mol_type, $release);
    });
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;