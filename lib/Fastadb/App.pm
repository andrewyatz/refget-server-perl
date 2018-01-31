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

  $self->cors();

  # Install the schema helper
  $self->helper(db => sub { $self->app()->schema() });

  # Route commands through the application
  my $r = $self->routes;

  #Routes that just work inline
  $r->get('/ping' => {ping => ''} => sub {
    my $c = shift;
    $c->render(text => "Ping");
  });
  $r->options('/options' => sub {
    my $c = shift;
    $c->render(text => "OPTIONS");
  });

  # Things that go to a controller
  $r->get('/sequence/:id')->to(controller => 'seq', action => 'id');
  $r->get('/metadata/:id')->to(controller => 'metadata', action => 'id');
  $r->post('/batch/sequence')->to(controller => 'batchseq', action => 'batch');

  # New content type of FASTA
  $self->types->type(fasta => 'text/x-fasta');
}

sub cors {
  my ($self) = @_;
  $self->hook(
    before_dispatch => sub {
      my $c = shift;
      if($c->req->headers->header('Origin')) {
        $c->res->headers->header( 'Access-Control-Allow-Origin' => '*' );
        $c->res->headers->header( 'Access-Control-Allow-Methods' => 'GET, OPTIONS' );
        $c->res->headers->header( 'Access-Control-Max-Age' => 2592000 );
        $c->res->headers->header( 'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With' );
      }
    }
  );
  return;
}

1;
