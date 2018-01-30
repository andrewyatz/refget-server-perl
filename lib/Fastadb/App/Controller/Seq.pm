package Fastadb::App::Controller::Seq;

use Mojo::Base 'Mojolicious::Controller';

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $start = $self->param('start');
  my $end = $self->param('end');

  if($self->req->headers->range() || ($start && $end && $start > $end)) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }

  my $seq = $self->db()->resultset('Seq')->get_seq($id);
  if(!$seq) {
    return $self->render(text => 'Not Found', status => 404);
  }
  if($start && $start > $seq->size()) {
    return $self->render(text => 'Invalid Range', status => 400);
  }

  $self->respond_to(
    txt => { data => $seq->get_seq($start, $end) },
    fasta => { data => $seq->to_fasta($start, $end) },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;