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
package Refget::App::Controller::Batchseq;

use Mojo::Base 'Mojolicious::Controller';

sub batch {
	my ($self) = @_;
	my $ids = $self->every_param('id');

  my @results;
  foreach my $id (@{$ids}) {
    my $r = { id => $id, found => 0 };
    my $seq = $self->db()->resultset('Seq')->get_seq($id);
    if($seq) {
      $r->{found} = 1;
      $r->{trunc512} = $seq->trunc512();
      $r->{seq} = $self->seq_fetcher->get_seq($seq);
    }
    push(@results, $r);
  }

  $self->respond_to(
    json => { json => \@results },
    any => { data => 'Not Acceptable', status => 406 }
  );
}

1;