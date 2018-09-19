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
