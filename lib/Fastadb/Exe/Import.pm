package Fastadb::Exe::Import;

use strict;
use warnings;

use Moose;

has 'schema'    => ( isa => 'Fastadb::Schema', is => 'ro', required => 1 );
has 'fasta'     => ( isa => 'Fastadb::Fmt::Fasta', is => 'ro', required => 1 );
has 'species'   => ( isa => 'Str', is => 'ro', required => 1 );
has 'division'  => ( isa => 'Str', is => 'ro', required => 1 );
has 'release'   => ( isa => 'Int', is => 'ro', required => 1 );

sub run {
  my ($self) = @_;
  my $fasta = $self->fasta();
  my ($species, $division, $release, $seq_type);

  $self->schema->txn_do(sub {
    $species = $self->schema->resultset('Species')->create_entry($self->species());
    $division = $self->schema->resultset('Division')->create_entry($self->division());
    $release = $self->schema->resultset('Release')->create_entry($self->release(), $division, $species);
    $seq_type = $self->schema->resultset('SeqType')->create_entry($self->fasta()->seq_type());
  });

  my $rs = $self->schema->resultset('Seq');
  while(my $seq = $fasta->iterate()) {
    $self->schema->txn_do(sub {
      $rs->create_seq($seq, $seq_type, $release);
    });
  }
  return;
}

1;