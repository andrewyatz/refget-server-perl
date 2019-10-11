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
use strict;
use warnings;
use Test::More;

use Refget::Util qw/ga4gh_digest ga4gh_to_trunc512/;
use Refget::Fmt::Fasta;
use File::Basename qw/dirname/;
use File::Spec;

my $ga4gh = ga4gh_digest('ACGT');
is($ga4gh, 'ga4gh:SQ.aKF498dAxcJAqme6QYQ7EZ07-fiw8Kw2', 'Check basic round tripping of ga4gh digest');
is(ga4gh_to_trunc512($ga4gh), '68a178f7c740c5c240aa67ba41843b119d3bf9f8b0f0ac36', 'Checking we can go back to trunc512 from ga4gh');

my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');

my $fasta_iter = Refget::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
is(
  ga4gh_digest($fasta_iter->iterate()->{sequence}),
  'ga4gh:SQ.so5U6XIpe4gySYPhiyBCBHCsrDG6_4Ug',
  'Checking basic encoding of known sequence test1'
);
is(
  ga4gh_digest($fasta_iter->iterate()->{sequence}),
  'ga4gh:SQ.mZaH9yJZKglZq7R1h5zLOyAGTQrXu72F',
  'Checking basic encoding of known sequence test2'
);
is(
  ga4gh_digest($fasta_iter->iterate()->{sequence}),
  'ga4gh:SQ.IbT0vZ5k7TVcPrZ2oo6-2vbY8XvcNlmV',
  'Checking basic encoding of known sequence test3'
);

done_testing();