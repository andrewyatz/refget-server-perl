# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
