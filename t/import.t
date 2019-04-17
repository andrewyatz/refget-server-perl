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
use Test::File;
use File::Basename qw/dirname/;
use File::Spec;
use File::Temp qw/tempdir/;
use Refget::Fmt::Fasta;
use Refget::Exe::Import;
use Refget::Exe::DefaultDicts;
use Refget::SeqStore::File;
use Refget::SeqStore::DBIx;

use Test::DBIx::Class {
  schema_class => 'Refget::Schema',
	resultsets => [qw/MolType Division Seq RawSeq/],
};

my ($release, $species, $division, $assembly) = (1, 'yeast', 'ensembl', 'R64-1-1');
my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');

my $lookup = {
	seq1 => { trunc512 => 'b28e54e972297b88324983e18b20420470acac31baff8520', path => File::Spec->catdir(qw/b2 8e/), content => qr/^ACCCGGTTGG/, subseq => ['CCG', 2, 5] },
	seq2 => { trunc512 => '999687f722592a0959abb475879ccb3b20064d0ad7bbbd85', path => File::Spec->catdir(qw/99 96/), content => qr/^ACGTACGT$/, subseq => ['CGTACGT', 1, undef] },
	seq3 => { trunc512 => '21b4f4bd9e64ed355c3eb676a28ebedaf6d8f17bdc365995', path => File::Spec->catdir(qw/21 b4/), content => qr/^A$/, subseq => ['A', undef, undef]  },
};

my $run_import = sub  {
	my ($seq_store) = @_;
	my $fasta = Refget::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
	Refget::Exe::DefaultDicts->new(schema => Schema)->run();
	my $import = Refget::Exe::Import->new(
		schema => Schema,
		seq_store => $seq_store,
		fasta => $fasta,
		release => $release,
		species => $species,
		division => $division,
		assembly => $assembly,
		verbose => 1,
		# making sure we commit everything and have to clean-up a final commit
		commit_rate => 2,
	);
	$import->run();

	# Start tests
	my $seqs_count = Seq->count({});
	is($seqs_count, 3, 'Checking we have three seq rows inserted');
};

my $test_subseq = sub {
	my ($seq_store) = @_;
	foreach my $seq_name (sort keys %{$lookup}) {
		my $checksum = $lookup->{$seq_name}->{trunc512};
		my $seq_obj = Seq->find({ trunc512 => $checksum});
		ok(defined $seq_obj, "Got seq_obj back for checksum ${checksum}");
		my ($expected, $start, $end) = @{$lookup->{$seq_name}->{subseq}};
		my $subseq = $seq_store->get_seq($seq_obj, $start, $end);
		$start //= 'undef';
		$end //= 'undef';
		my $msg = qq{Checking subseq retrieval of (start: ${start} | end: ${end})};
		is($subseq, $expected, $msg);
	}
};

# Testing the file based storage system
{
	my $root_dir = tempdir(TMPDIR => 1, CLEANUP => 1);
	my $seq_store = Refget::SeqStore::File->new(root_dir => $root_dir);
	$run_import->($seq_store);

	foreach my $seq_name (sort keys %{$lookup}) {
		my $hash = $lookup->{$seq_name};
		my $checksum =$hash->{trunc512};
		my $target = File::Spec->catfile($root_dir, $hash->{path}, $checksum);
		note $target;
		file_exists_ok($target, "${seq_name} ($checksum) exists");
		file_not_empty_ok($target, "${seq_name} file is not empty");
		file_readable_ok($target, "${seq_name} file is readable");
		file_line_count_is($target, 1, "${seq_name} file has one line");
		file_contains_like($target, $hash->{content}, "${seq_name} file content is as expected ".$hash->{content});
	}

	# Test subseq retrieval
	$test_subseq->($seq_store);
}

reset_schema;

# Testing the database based storage system
{
	my $seq_store = Refget::SeqStore::DBIx->new(schema => Schema);
	$run_import->($seq_store);
	my $seqs_count = RawSeq->count({});
	is($seqs_count, 3, 'Checking we have three raw_seq rows inserted');
	foreach my $seq_name (sort keys %{$lookup}) {
		my $hash = $lookup->{$seq_name};
		my $raw_seq = RawSeq->find($hash->{trunc512});
		ok(defined $raw_seq, "Found a row for ".$hash->{trunc512});
		like($raw_seq->seq(), $hash->{content}, "${seq_name} content is as expected ".$hash->{content});
	}

	# Test subseq retrieval
	$test_subseq->($seq_store);
}

done_testing();
