#!/usr/bin/env perl

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

# Populate seq types
create('SeqType', 'seq_type', [qw/
  protein
  cds
  cdna
  ncrna
/]);

sub create {
  my ($rs_key, $method, $values) = @_;
  print "Creating dict entries for $rs_key"."\n";
  my @objs = @{$schema->resultset($rs_key)->create_entries($values)};
  print "Created '".$_->$method()."'\n" for @objs;
  print "\n";
}
