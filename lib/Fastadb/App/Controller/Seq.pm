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
package Fastadb::App::Controller::Seq;

use Mojo::Base 'Mojolicious::Controller';
use Fastadb::Util qw/allowed_algorithm/;

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $start = $self->param('start');
  my $end = $self->param('end');

  my $seq_obj = $self->db()->resultset('Seq')->get_seq($id);
  my $sub_seq = $self->db()->resultset('SubSeq');
  if(!$seq_obj) {
    return $self->render(text => 'Not Found', status => 404);
  }
  my $seq_size = $seq_obj->size();

  my $range = $self->req->headers->range;
  if($range) {
    if($start || $end) {
      return $self->render(text => 'Invalid Input', status => 400);
    }
    #Parse header. Increase end by one as byte ranges are always from 0
    if(($start,$end) = $range =~ /^bytes=(\d+)-(\d+)$/) {
      $end++;
    }
    else {
      return $self->render(text => 'Invalid Input', status => 400);
    }
    if($seq_obj->circular() && $start > $end) { # cannot request circs across the ori using range
      return $self->render(text => 'Range Not Satisfiable', status => 416);
    }
    if($start >= $seq_size) {
      return $self->render(text => 'Range Not Satisfiable', status => 416) if defined $end;
      return $self->render(text => 'Bad Request', status => 400);
    }

    $end = $seq_size if $end > $seq_size;
  }

  return $self->render(text => 'Bad Request', status => 400) if defined $start && $start !~ /^\d+$/;
  return $self->render(text => 'Bad Request', status => 400) if defined $end && $end !~ /^\d+$/;

  if(!$seq_obj->circular()) {
    if($start && $end && $start > $end) {
      return $self->render(text => 'Range Not Satisfiable', status => 416);
    }
  }
  if($start && $start >= $seq_size) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }
  if($end && $end > $seq_size) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }

  if(defined $start || defined $end) {
    $self->res->headers->accept_ranges('none');
  }

  # Now check for status and set to 206 for partial rendering if we got a subseq from
  # Range but not the whole sequence
  my $status = 200;
  if($range) {
    my $requested_size = $end-$start;
    if($requested_size != $seq_size) {
      $status = 206;
    }
  }

  $self->respond_to(
    txt => sub { $self->render(data => $seq_obj->get_seq($sub_seq, $start, $end), status => $status); },
    fasta => sub { $self->render(data => $seq_obj->to_fasta($sub_seq, $start, $end)); },
    any => { data => 'Unsupported Media Type', status => 406 }
  );
}

1;