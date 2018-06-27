package Fastadb::App;

use Mojo::Base 'Mojolicious';

use Mojo::URL;
use Fastadb::Schema;
use IO::Compress::Gzip 'gzip';

our $API_VERSION = '1.0.0';
our $API_VND = 'vnd.ga4gh.seq.v'.$API_VERSION;

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
  $self->gzip_encoding();

  # Install the schema helper
  $self->helper(db => sub { $self->app()->schema() });

  # Route commands through the application
  my $r = $self->routes;

  # Default routes
  $r->get('/ping' => {ping => ''} => sub {
    my $c = shift;
    $c->render(text => "Ping");
  });

  # Things that go to a controller
  $r->get('/ping')->to(controller => 'service', action => 'ping');
  $r->get('/service-info')->to(controller => 'service', action => 'service');
  $r->get('/sequence/:id')->to(controller => 'seq', action => 'id', gzip => 1);
  $r->get('/sequence/:id/metadata')->to(controller => 'metadata', action => 'id', gzip => 1);
  $r->post('/batch/sequence')->to(controller => 'batchseq', action => 'batch', gzip => 1);

  # New content types
  $self->custom_content_types();
  $self->helper(content_specified => sub {
    my ($c) = @_;
    return 1 if $c->req->param('format');
    return 1 if $c->stash->{'format'};
    return 1 if @{$c->app->types->detect($c->req->headers->accept)};
    return 0;
  });
}

sub cors {
  my ($self) = @_;
  #Sledgehammer; support CORS on all URL requests by intercepting everything, sniffing for OPTIONS and then
  #choosing to move onto the next action or bailing out with a CORS response
  $self->hook( around_dispatch => sub {
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
  });
  return;
}

sub custom_content_types {
  my ($self) = @_;
  my $types = $self->types();

  # Support all types of text
  $types->type(txt => ["text/${API_VND}+plain; charset=us-ascii", "text/${API_VND}+plain", 'text/plain']);

  # Support all types of JSON
  $types->type(json => ["application/${API_VND}+json", 'application/json']);

  # Support FASTA
  $types->type(fasta => 'text/x-fasta');
  return;
}

# Support TE based encoding 1st, as the spec defines, but also Accept-Encoding (the more generally supported version)
sub gzip_encoding {
  my ($self) = @_;
  $self->hook(after_render => sub {
    my ($c, $output, $format) = @_;
    # Check if "gzip => 1" has been set in the stash
    return unless $c->stash->{gzip};

    # Check for TE first
    my $chunk = 0;
    if(($c->req->headers->te // q{}) =~ /gzip/i) {
      $c->res->headers->transfer_encoding('chunked, gzip');
      $chunk = 1;
    }
    # Then check for Accept-Encoding
    elsif(($c->req->headers->accept_encoding // q{}) =~ /gzip/i) {
      $c->res->headers->vary('Accept-Encoding');
      $c->res->headers->content_encoding('gzip');
    }
    # If not then return without compression
    else {
      return;
    }

    #Compress
    gzip $output, \my $compressed;

    # Write chunk or just set output
    if($chunk) {
      # Odd bug squished. With Content-Encoding didn't need this but Transfer-Encoding does need it
      $c->res->headers->append('Content-Length' => length($compressed));
      # Second odd bug where we have to write a chunk and then finish it because we now use
      # transfer encoding. I think it's something in Mojo that's doing this link but
      # this solves it

      $c->write_chunk($compressed => sub {
        $c->finish();
      });
    }
    else {
      $$output = $compressed;
    }
  });
}

1;
