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
