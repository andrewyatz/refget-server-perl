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
use File::Basename qw/dirname/;
use File::Spec;
use Fastadb::Fmt::Fasta;
use Fastadb::Exe::Import;
use Fastadb::Exe::DefaultDicts;

use Test::DBIx::Class {
  schema_class => 'Fastadb::Schema',
	resultsets => [qw/MolType Division/],
};

my ($release, $species, $division, $assembly) = (1, 'yeast', 'ensembl', 'R64-1-1');
my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');
my $fasta = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');

Fastadb::Exe::DefaultDicts->new(schema => Schema)->run();
my $import = Fastadb::Exe::Import->new(
	schema => Schema,
	fasta => $fasta,
	release => $release,
	species => $species,
	division => $division,
	assembly => $assembly,
);
$import->run();

my $seqs_count = Schema->resultset('Seq')->count({});
is(3, $seqs_count, 'Checking we have three rows inserted');

done_testing();
