package Fastadb::App::Controller::Seq;

use Mojo::Base 'Mojolicious::Controller';

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $start = $self->param('start');
  my $end = $self->param('end');

  my $range = $self->req->headers->range;
  if($range) {
    if($start || $end) {
      return $self->render(text => 'Invalid Input', status => 400);
    }
    #Parse header. Increase end by one as byte ranges are always from 0
    if(($start,$end) = $range =~ /(\d+)-(\d+)/) {
      $end++;
    }
    else {
      return $self->render(text => 'Invalid Input', status => 400);
    }
  }

  my $seq_obj = $self->db()->resultset('Seq')->get_seq($id);
  my $sub_seq = $self->db()->resultset('SubSeq');
  if(!$seq_obj) {
    return $self->render(text => 'Not Found', status => 404);
  }
  my $seq_size = $seq_obj->size();
  # Only when we're handling circular sequences
  if(!$seq_obj->circular() && ($start && $end && $start > $end)) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }
  if($start && $start > $seq_size) {
    return $self->render(text => 'Invalid Range', status => 400);
  }
  if($end && $end > $seq_size) {
    return $self->render(text => 'Invalid Range', status => 400);
  }

  # Now check for status and set to 206 for partial rendering if we got a subseq from
  # Range but not the whole sequence
  my $status = 200;
  if($range) {
    $self->res->headers->accept_ranges('none');
    my $requested_size = $end-$start;
    if($requested_size != $seq_size) {
      $status = 206;
    }
  }

  $self->respond_to(
    txt => sub { $self->render(data => $seq_obj->get_seq($sub_seq, $start, $end), status => $status); },
    fasta => sub { $self->render(data => $seq_obj->to_fasta($sub_seq, $start, $end)); },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;