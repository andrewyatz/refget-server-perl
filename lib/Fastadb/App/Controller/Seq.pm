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

  my $seq = $self->db()->resultset('Seq')->get_seq($id);
  if(!$seq) {
    return $self->render(text => 'Not Found', status => 404);
  }
  # Only when we're handling circular sequences
  if(!$seq->circular() && ($start && $end && $start > $end)) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }
  if($start && $start > $seq->size()) {
    return $self->render(text => 'Invalid Range', status => 400);
  }
  if($end && $end > $seq->size()) {
    return $self->render(text => 'Invalid Range', status => 400);
  }

  $self->respond_to(
    txt => { data => $seq->get_seq($start, $end) },
    fasta => { data => $seq->to_fasta($start, $end) },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;