package Fastadb::App;

use Mojo::Base 'Mojolicious';

use Mojo::URL;
use Fastadb::Schema;

# Connects once for entire application. For real apps, consider using a helper
# that can reconnect on each request if necessary.
has schema => sub {
  my @dbargs = Fastadb::Schema->generate_db_args();
	return Fastadb::Schema->connect(@dbargs);
};

sub startup {
  my ($self) = @_;

  # Configure hypnotoad
  if(exists $ENV{APP_PID_FILE}) {
    $self->config(hypnotoad => {
      proxy => 1,
      pid_file => $ENV{APP_PID_FILE},
    });
  }

  # Install the schema helper
  $self->helper(db => sub { $self->app()->schema() });

  # Route commands through the application
  my $r = $self->routes;
  $r->get('/ping' => {ping => ''} => sub {
    my ($c) = @_;
    $c->render(text => "Ping");
  });
  $r->get('/sequence/:id')->to(controller => 'seq', action => 'id');
  $r->get('/metadata/:id')->to(controller => 'metadata', action => 'id');
  $r->post('/batch/sequence')->to(controller => 'batchseq', action => 'batch');

  # New content type of FASTA
  $self->types->type(fasta => 'text/x-fasta');
}

1;
