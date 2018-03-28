package Fastadb::App::Controller::Metadata;

use Mojo::Base 'Mojolicious::Controller';

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $no_full_object = 0;
  my $seq = $self->db()->resultset('Seq')->get_seq($id, undef, $no_full_object);

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
    my $synonyms = $m->synonyms();
    if($synonyms != 0) {
      foreach my $s ($synonyms->next()) {
        push(@aliases, { alias => $s->synonym() });
      }
    }
  }
  # Check for content specification. If nothing was specified then set to json
  if(!$self->content_specified()) {
    $self->stash->{format} = 'json';
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