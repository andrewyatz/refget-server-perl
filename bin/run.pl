#!/usr/bin/env perl

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
use Refget::Schema;
use Refget::Fmt::Fasta;
use Refget::Exe::Import;
use Refget::SeqStore::File;

my ($file, $release, $mol_type, $species, $division, $assembly, $root_dir, $commit_rate) = @ARGV;

my @dbargs = Refget::Schema->generate_db_args();
my $schema = Refget::Schema->connect(@dbargs);

my $fasta = Refget::Fmt::Fasta->new(file => $file, type => $mol_type);
my $seq_store = Refget::SeqStore::File->new(root_dir => $root_dir);
my $import = Refget::Exe::Import->new(
  schema => $schema,
  seq_store => $seq_store,
  fasta => $fasta,
  release => $release,
  species => $species,
  division => $division,
  assembly => $assembly,
  root_dir => $root_dir,
  commit_rate => $commit_rate,
);

$import->run();
