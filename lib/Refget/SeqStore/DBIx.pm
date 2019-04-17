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
package Refget::SeqStore::DBIx;

use Moose;
use namespace::autoclean;

with 'Refget::SeqStore::Base';

has 'schema' => (isa => 'Refget::Schema', is => 'ro', required => 1);

sub store {
  my ($self, $seq_obj, $sequence) = @_;
  my $checksum = $self->get_checksum_from_seq($seq_obj);
  my $rs = $self->schema->resultset('RawSeq');
  my $raw_seq = $rs->find_or_create({ checksum => $checksum, seq => $sequence });
  return $raw_seq;
}

sub _sub_seq {
  my ($self, $start, $length, $seq_obj) = @_;
  my $checksum = $self->get_checksum_from_seq($seq_obj);
  my $subseq_rs = $self->schema->resultset('SubSeq');
  my $rs = $subseq_rs->search( {}, { bind => [ $start, $length, $checksum ] } );
  return $rs->next()->seq();
}

__PACKAGE__->meta->make_immutable;

1;
