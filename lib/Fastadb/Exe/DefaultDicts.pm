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