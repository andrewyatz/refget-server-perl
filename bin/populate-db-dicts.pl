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

my @dbargs = Fastadb::Schema->generate_db_args();
my $schema = Fastadb::Schema->connect(@dbargs);

# Populate divisions
create('Division', 'division', [qw/
  ensembl
  plants
  protists
  bacteria
  metazoa
  fungi
/]);

# Populate mol types
create('MolType', 'mol_type', [qw/
  protein
  cds
  cdna
  ncrna
  dna
/]);

sub create {
  my ($rs_key, $method, $values) = @_;
  print "Creating dict entries for $rs_key"."\n";
  my @objs = @{$schema->resultset($rs_key)->create_entries($values)};
  print "Created '".$_->$method()."'\n" for @objs;
  print "\n";
}
