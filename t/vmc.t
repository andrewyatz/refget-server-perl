use strict;
use warnings;
use Test::More;

use Fastadb::Util qw/vmc_digest/;
use Fastadb::Fmt::Fasta;
use File::Basename qw/dirname/;
use File::Spec;

is(vmc_digest('ACGT'), 'VMC:GS_aKF498dAxcJAqme6QYQ7EZ07-fiw8Kw2', 'Check basic round tripping of VMC digest');

my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');

my $fasta_iter = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
is(
  vmc_digest($fasta_iter->iterate()->{sequence}),
  'VMC:GS_so5U6XIpe4gySYPhiyBCBHCsrDG6_4Ug',
  'Checking basic encoding of known sequence test1'
);
is(
  vmc_digest($fasta_iter->iterate()->{sequence}),
  'VMC:GS_mZaH9yJZKglZq7R1h5zLOyAGTQrXu72F',
  'Checking basic encoding of known sequence test2'
);
is(
  vmc_digest($fasta_iter->iterate()->{sequence}),
  'VMC:GS_IbT0vZ5k7TVcPrZ2oo6-2vbY8XvcNlmV',
  'Checking basic encoding of known sequence test3'
);

done_testing();