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
package Refget::SeqStore::Base;

use Moose::Role;

requires '_sub_seq';
requires '_store';

has 'checksum' => (isa => 'Str', is => 'ro', required => 1, default => 'trunc512');

# Give us the sequence object and range requested
sub get_seq {
  my ($self, $seq_obj, $start, $end) = @_;

  my $seq_size = $seq_obj->size();
  $start = 0 if ! defined $start;
  $end = $seq_size if ! defined $end;

  my $checksum = $self->get_checksum_from_seq($seq_obj);

  my $sequence;
  # We are in a circular sequence call
  if($start > $end && $seq_obj->circular()) {
    my $subseq = $self->_sub_seq($checksum, $start, ($seq_size-$start));
		$subseq .= $self->_sub_seq($checksum, 0, $end);
		$sequence = $subseq;
  }
  else {
    my $length = $end - $start;
    $sequence = $self->_sub_seq($checksum, $start, $length);
  }

  return $sequence;
}

sub store {
  my ($self, $seq_obj, $sequence) = @_;
  my $checksum = $self->get_checksum_from_seq($seq_obj);
  return $self->_store($checksum, $sequence);
}

sub get_checksum_from_seq {
  my ($self, $seq_obj) = @_;
  my $checksum_type = $self->checksum();
  my $checksum_sub = $seq_obj->can($checksum_type);
  if(!$checksum_sub) {
    confess "Cannot call '${checksum_type} on the sequence object";
  }
  return $checksum_sub->($seq_obj);
}

1;
