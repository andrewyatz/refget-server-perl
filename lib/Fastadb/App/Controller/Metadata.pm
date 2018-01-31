package Fastadb::App::Controller::Metadata;

use Mojo::Base 'Mojolicious::Controller';

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $seq = $self->db()->resultset('Seq')->get_seq($id);

  if(!$seq) {
    return $self->render(text => 'Not Found', status => 404);
  }

  my @aliases = (
    { alias => $seq->md5(), },
    { alias => $seq->sha1(), },
    { alias => $seq->sha256(), },
  );
  my $molecules = $seq->molecules();
  foreach my $m ($molecules->next()) {
    push(@aliases, { alias => $m->id });
  }
  $self->respond_to(
    json => { json => {
      metadata => {
        id => $id,
        length => $seq->size(),
        aliases => \@aliases
      }
    }},
    any  => {data => 'Unsupported Media Type', status => 415}
  );
}

1;