use strict;
use warnings;

use Test::More;
use Test::Differences;
use IO::Scalar;
use File::Basename qw/dirname/;
use File::Spec;

use Fastadb::Fmt::Fasta;

my $expected = [
  { id => 'seq1', additional => q{test additional data}, sequence => 'ACCCGGTTGGGCCCCGGGTTTGGCNACCCGGTTGGGCCCCGGG', type => 'dna'},
  { id => 'seq2', additional => q{}, sequence => 'ACGTACGT', type => 'dna'},
  { id => 'seq3', additional => q{}, sequence => 'A', type => 'dna'},
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
  my $fasta_iter = Fastadb::Fmt::Fasta->new(fh => $fasta_io, type => 'dna');
  test_fasta($fasta_iter, 'In-memory open filehandle');
}

sub filename {
  my $fasta_iter = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
  test_fasta($fasta_iter, 'Filename uncompressed');
}

sub filename_compressed {
  my $fasta_iter = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa.gz'), type => 'dna');
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