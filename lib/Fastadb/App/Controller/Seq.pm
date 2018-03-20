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
    if(($start,$end) = $range =~ /(\d+)-(\d+)/) {
      $start--; # switch into ga4gh 0 based coords
    }
    else {
      return $self->render(text => 'Invalid Input', status => 400);
    }
  }

  if($start && $end && $start > $end) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }

  my $seq_obj = $self->db()->resultset('Seq')->get_seq($id);
  if(!$seq_obj) {
    return $self->render(text => 'Not Found', status => 404);
  }
  if($start && $start > $seq_obj->size()) {
    return $self->render(text => 'Invalid Range', status => 400);
  }
  my $sub_seq = $self->db()->resultset('SubSeq');
  $self->respond_to(
    txt => { data => $seq_obj->get_seq($sub_seq, $start, $end) },
    fasta => { data => $seq_obj->to_fasta($sub_seq, $start, $end) },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;