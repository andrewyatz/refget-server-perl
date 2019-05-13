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

sub _store {
  my ($self, $checksum, $sequence) = @_;
  my $rs = $self->schema->resultset('RawSeq');
  my $raw_seq = $rs->find_or_create({ checksum => $checksum, seq => $sequence });
  return $raw_seq;
}

sub _sub_seq {
  my ($self, $checksum, $start, $length) = @_;
  return q{} if $length == 0; # return a blank string if we were asked for a 0 length string
  my $subseq_rs = $self->schema->resultset('SubSeq');
  my $rs = $subseq_rs->search( {}, { bind => [ $start, $length, $checksum ] } );
  return $rs->next()->seq();
}

__PACKAGE__->meta->make_immutable;

1;
