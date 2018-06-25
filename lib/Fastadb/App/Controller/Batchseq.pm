package Fastadb::App::Controller::Batchseq;

use Mojo::Base 'Mojolicious::Controller';

sub batch {
	my ($self) = @_;
	my $ids = $self->every_param('id');

  my @results;
  my $subseq = $self->db()->resultset('SubSeq');
  foreach my $id (@{$ids}) {
    my $r = { id => $id, found => 0 };
    my $seq = $self->db()->resultset('Seq')->get_seq($id);
    if($seq) {
      $r->{found} = 1;
      $r->{trunc512} = $seq->trunc512();
      $r->{seq} = $seq->get_seq($subseq);
    }
    push(@results, $r);
  }

  $self->respond_to(
    json => { json => \@results },
    any => { data => 'Unsupported Media Type', status => 415 }
  );
}

1;