use strict;
use warnings;

use Test::More;
use File::Basename qw/dirname/;
use File::Spec;
use Fastadb::Fmt::Fasta;
use Fastadb::Exe::Import;

use Test::DBIx::Class {
  schema_class => 'Fastadb::Schema',
	resultsets => [qw/MolType/],
};

my ($release, $species, $division) = (1, 'yeast', 'ensembl');
my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');
my $fasta = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');

MolType->create({type => 'dna'});
my $import = Fastadb::Exe::Import->new(
	schema => Schema,
	fasta => $fasta,
	release => $release,
	species => $species,
	division => $division
);
$import->run();

my $seqs_count = Schema->resultset('Seq')->count({});
is(3, $seqs_count, 'Checking we have three rows inserted');

done_testing();
