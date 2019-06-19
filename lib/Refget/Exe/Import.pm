# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
package Refget::Exe::Import;

use strict;
use warnings;

use Moose;
use Refget::SeqStore::File;
use Carp qw/confess/;

has 'schema'      => ( isa => 'Refget::Schema', is => 'ro', required => 1 );
has 'seq_store'   => ( isa => 'Refget::SeqStore::Base', is => 'ro', required => 1 );
has 'fasta'       => ( isa => 'Refget::Fmt::Fasta', is => 'ro', required => 1 );
has 'species'     => ( isa => 'Str', is => 'ro', required => 1 );
has 'division'    => ( isa => 'Str', is => 'ro', required => 1 );
has 'release'     => ( isa => 'Int', is => 'ro', required => 1 );
has 'assembly'    => ( isa => 'Str', is => 'ro', required => 1 );
has 'source'      => ( isa => 'Str', is => 'ro', required => 1, default => 'unknown' );
has 'commit_rate' => ( isa => 'Int', is => 'ro', required => 1, default => 1 );
has 'verbose'     => ( isa => 'Bool', is => 'ro', required => 1, default => 1 );

sub run {
  my ($self) = @_;
  my $fasta = $self->fasta();
  my $seq_store = $self->seq_store();
  my ($species, $division, $release, $mol_type, $source);

  $self->schema->txn_do(sub {
    $species = $self->schema->resultset('Species')->create_entry($self->species(), $self->assembly());
    $division = $self->schema->resultset('Division')->create_entry($self->division());
    $release = $self->schema->resultset('Release')->create_entry($self->release(), $division, $species);
    $mol_type = $self->schema->resultset('MolType')->find_entry($self->fasta()->type());
    $source = $self->schema->resultset('Source')->find_entry($self->source());
  });
  if(! defined $mol_type) {
    confess('No molecule_type in the database found for '.$self->fasta()->type());
  }
  if(! defined $source) {
    confess('No source in the database found for '.$self->source());
  }

  my $rs = $self->schema->resultset('Seq');
  my $guard = $self->schema->txn_scope_guard();
  my $count = 0;
  my $commit_rate = $self->commit_rate();
  my $verbose = $self->verbose();
  while(my $seq = $fasta->iterate()) {
    printf("Processing sequence %s ... ", $seq->{id}) if $verbose;
    my $seq_obj = $rs->create_seq($seq, $mol_type, $release, $source);
    $seq_store->store($seq_obj->seq(), $seq->{sequence});
    print("done\n")if $verbose;
    $count++;
    if($count == $commit_rate) {
      $guard->commit();
      $guard = $self->schema->txn_scope_guard();
      $count = 0;
    }
  }
  $guard->commit();
  return;
}

__PACKAGE__->meta->make_immutable;

1;