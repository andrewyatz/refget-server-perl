#!/usr/bin/env perl

use Fastadb::Schema;
# my $dsn = 'dbi:SQLite:test.db';
my $schema = Fastadb::Schema->connect($dsn);
$schema->create_ddl_dir([qw/MySQL SQLite PostgreSQL/], $Fastadb::Schema::VERSION, './schema/');
#  $schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
#                          '0.4',
#                          './schemas/',
#                          '0.3'
#                          );
