use Test::More;

use strict;
use warnings;

use Test::Mojo;
my $t = Test::Mojo->new('Fastadb::App');

my $origin = q{http://www.example.org};
$t->options_ok('/' => { Origin => $origin, 'Access-Control-Request-Method' => 'GET' } )
  ->status_is(200)
  ->header_is('access-control-allow-origin', $origin)
  ->header_is('access-control-allow-headers', 'Content-Type, Authorization, X-Requested-With, api_key, Range')
  ->header_is('access-control-allow-methods', 'GET, OPTIONS')
  ->header_is('access-control-max-age', 2592000);

$t->get_ok('/ping' => {Origin => $origin})
  ->status_is(200)
  ->header_is('access-control-allow-origin', $origin)
  ->header_like('access-control-expose-headers', qr/Cache-Control/);

done_testing();
