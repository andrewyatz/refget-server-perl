package Fastadb::App::Controller::Metadata;

use Mojo::Base 'Mojolicious::Controller';
use Fastadb::Util qw/allowed_algorithm/;
sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $algorithm = $self->param('algorithm');

  if($algorithm && !allowed_algorithm($algorithm)) {
    return $self->render(text => 'Bad Request', status => 400);
  }

  my $no_full_object = 0;
  my $seq = $self->db()->resultset('Seq')->get_seq($id, $algorithm, $no_full_object);

  if(!$seq) {
    return $self->render(text => 'Not Found', status => 404);
  }

  my @aliases = (
    { alias => $seq->vmcdigest(), naming_authority => 'vmc' },
  );
  my $molecules = $seq->molecules();
  foreach my $m ($molecules->next()) {
    next if ! defined $m;
    push(@aliases, { alias => $m->id, naming_authority => 'unknown' });
    my $synonyms = $m->synonyms();
    if($synonyms != 0) {
      foreach my $s ($synonyms->next()) {
        push(@aliases, { alias => $s->synonym(), naming_authority => 'unknown' });
      }
    }
  }

  $self->respond_to(
    json => { json => {
      metadata => {
        length => $seq->size(),
        md5 => $seq->md5,
        trunc512 => $seq->trunc512,
        aliases => \@aliases
      }
    }},
    any  => {data => 'Unsupported Media Type', status => 415}
  );
}

1;