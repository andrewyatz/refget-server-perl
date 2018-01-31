use Test::More;

use strict;
use warnings;

use Test::Mojo;
my $t = Test::Mojo->new('Fastadb::App');

my $origin = q{http://www.example.org};
$t->options_ok('/' => { Origin => $origin } )
  ->status_is(200)
  ->header_is('access-control-allow-origin', $origin)
  ->header_is('access-control-allow-headers', 'Content-Type, Authorization, X-Requested-With')
  ->header_is('access-control-allow-methods', 'GET, OPTIONS')
  ->header_is('access-control-max-age', 2592000)
  ->header_is('access-control-allow-credentials', 'omit');

$t->get_ok('/ping' => { Origin => $origin } )
  ->status_is(200)
  ->header_is('access-control-allow-origin', $origin)
  ->header_is('access-control-allow-headers', 'Content-Type, Authorization, X-Requested-With')
  ->header_is('access-control-allow-methods', 'GET, OPTIONS')
  ->header_is('access-control-max-age', 2592000)
  ->header_is('access-control-allow-credentials', 'true')
  ->content_is('Ping');

$t->get_ok('/ping')
  ->status_is(200)
  ->header_isnt('access-control-allow-origin', $origin, 'No Origin means no CORS headers');

done_testing();
