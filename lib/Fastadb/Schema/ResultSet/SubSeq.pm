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
package Fastadb::Schema::ResultSet::SubSeq;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub get_seq {
  my ($self, $seq_obj, $start, $end) = @_;

  my $seq_size = $seq_obj->size();
  $start = 0 if ! defined $start;
  $end = $seq_size if ! defined $end;

  my $sequence;
  # We are in a circular sequence call
  if($start > $end && $seq_obj->circular()) {
    my $subseq = $self->_sub_seq($start, ($seq_size-$start), $seq_obj);
		$subseq .= $self->_sub_seq(0, $end, $seq_obj);
		$sequence = $subseq;
  }
  else {
    my $length = $end - $start;
    $sequence = $self->_sub_seq($start, $length, $seq_obj);
  }

  return $sequence;
}

sub _sub_seq {
  my ($self, $start, $length, $seq_obj) = @_;
  my $rs = $self->search( {}, { bind => [ $start, $length, $seq_obj->trunc512() ] } );
  return $rs->next()->seq();
}

1;