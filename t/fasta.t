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
use Test::Differences;
use IO::Scalar;
use File::Basename qw/dirname/;
use File::Spec;

use Refget::Fmt::Fasta;

my $expected = [
  { id => 'seq1', additional => q{test additional data}, sequence => 'ACCCGGTTGGGCCCCGGGTTTGGCNACCCGGTTGGGCCCCGGG', type => 'dna', circular => 0},
  { id => 'seq2', additional => q{}, sequence => 'ACGTACGT', type => 'dna', circular => 0},
  { id => 'seq3', additional => q{}, sequence => 'A', type => 'dna', circular => 0},
];

my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');

open_fh();
filename();
filename_compressed();

sub open_fh {
  my $fasta = qq{>seq1 test additional data
ACCCGGTTGG
GCCCCGGGTT
TGGCNACCCG
GTTGGGCCCC
GGG
>seq2
ACGT
ACGT
>seq3
A
};
  my $fasta_io = IO::Scalar->new(\$fasta);
  my $fasta_iter = Refget::Fmt::Fasta->new(fh => $fasta_io, type => 'dna');
  test_fasta($fasta_iter, 'In-memory open filehandle');
}

sub filename {
  my $fasta_iter = Refget::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
  test_fasta($fasta_iter, 'Filename uncompressed');
}

sub filename_compressed {
  my $fasta_iter = Refget::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa.gz'), type => 'dna');
  test_fasta($fasta_iter, 'GZipped filename');
}

sub test_fasta {
  my ($fasta_iter, $msg) = @_;
  my @actual;
  while(my $seq = $fasta_iter->iterate()) {
    push(@actual, $seq);
  }
  eq_or_diff(\@actual, $expected, $msg.': checking iteration works');
}

done_testing();