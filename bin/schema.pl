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

use Refget::Schema;
use warnings;
use strict;
# my $dsn = 'dbi:SQLite:test.db';
my $dsn = undef;
my $schema = Refget::Schema->connect($dsn);
my $translator_args = { producer_args => { mysql_version => '5.0.3' }, quote_identifiers => 1 };
$schema->create_ddl_dir([qw/MySQL SQLite PostgreSQL/], $Refget::Schema::VERSION, './schema/', undef, $translator_args);
