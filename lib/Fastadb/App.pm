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
  $self->helper(db => sub { $self->app()->schema() });

  # Route commands through the application
  my $r = $self->routes;
  $r->any([qw/GET HEAD/] => '/sequence/:id')->to(controller => 'seq', action => 'id');
  $r->get('/metadata/:id')->to(controller => 'metadata', action => 'id');
}

1;