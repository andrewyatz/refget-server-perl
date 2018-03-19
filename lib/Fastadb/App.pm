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

  if(exists $ENV{APP_LOG_FILE}) {
    my $loglevel = $ENV{APP_LOG_LEVEL} || 'warn';
    $self->log(Mojo::Log->new(path => $ENV{APP_LOG_FILE}, level => $loglevel ));
  }

  if(exists $ENV{APP_ACCESS_LOG_FILE}) {
    my $logformat = $ENV{APP_ACCESS_LOG_FORMAT} || 'combinedio';
    $self->plugin(AccessLog => log => $ENV{APP_ACCESS_LOG_FILE}, format => $logformat);
  }

  $self->cors();

  # Install the schema helper
  $self->helper(db => sub { $self->app()->schema() });

  # Route commands through the application
  my $r = $self->routes;

  #Routes that just work inline
  #  $r->options('/*' => sub {
  #   my $c = shift;
  #   $c->render(text => q{});
  # });

  $r->get('/ping' => {ping => ''} => sub {
    my $c = shift;
    $c->render(text => "Ping");
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
  #Sledgehammer; support CORS on all URL requests by intercepting everything, sniffing for OPTIONS and then
  #choosing to move onto the next action or bailing out with a CORS response
  $self->hook(
    around_dispatch => sub {
      my $next = shift;
      my $c = shift;
      my $req = $c->req->headers();
      my $options_request = 0;
      if($req->origin) {
        my $resp = $c->res->headers();
        # If we have this we are in a pre-flight according to https://www.html5rocks.com/static/images/cors_server_flowchart.png
        if($c->req->method eq 'OPTIONS' && $req->header('access-control-request-method')) {
          $resp->header('Access-Control-Allow-Methods' => 'GET, OPTIONS');
          $resp->header('Access-Control-Max-Age' => 2592000);
          $resp->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With, api_key, Range');
          $options_request = 1;
        }
        else {
          $resp->header('Access-Control-Expose-Headers' => 'Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma');
        }

        $resp->header('Access-Control-Allow-Origin' => $req->header('Origin') );
      }

      if($options_request) {
        $c->render(text => q{}, status => 200);
      }
      else {
        $next->();
      }
    }
  );
  return;
}

1;
