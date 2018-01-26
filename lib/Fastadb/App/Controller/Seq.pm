package Fastadb::App::Controller::Seq;

use Mojo::Base 'Mojolicious::Controller';

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $start = $self->param('start');
  my $end = $self->param('end');
  my $seq = $self->db()->resultset('Seq')->get_seq($id, $start, $end);
  if($self->tx->req->method eq 'HEAD') {
    $self->app->log->debug('In a head request');
    # How do we find something
    return $self->render(text => q{});
  }
  $self->respond_to(
    txt => { data => $seq },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;