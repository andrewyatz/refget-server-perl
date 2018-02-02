#!/usr/bin/env perl

use strict;
use warnings;
use Fastadb::Schema;
use Fastadb::Fmt::Fasta;
use Fastadb::Exe::Import;

my ($file, $release, $mol_type, $species, $division, $assembly) = @ARGV;

my @dbargs = Fastadb::Schema->generate_db_args();
my $schema = Fastadb::Schema->connect(@dbargs);

my $fasta = Fastadb::Fmt::Fasta->new(file => $file, type => $mol_type);
my $import = Fastadb::Exe::Import->new(
  schema => $schema,
  fasta => $fasta,
  release => $release,
  species => $species,
  division => $division,
  assembly => $assembly,
);

$import->run();
