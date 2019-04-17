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
package Refget::Schema;

use strict;
use warnings;

our $VERSION = '1.0.0';

use base qw/DBIx::Class::Schema/;
use Mojo::URL;

__PACKAGE__->load_components(qw/InflateColumn::Boolean Core/);
__PACKAGE__->load_namespaces();

sub generate_db_args {
  my ($class) = @_;
  my @dbargs;

  # First check for DATABASE_URL from Heroku
  if(exists $ENV{DATABASE_URL}) {
		my $url = Mojo::URL->new($ENV{DATABASE_URL});
		my ($user,$pass);
    if($url->userinfo()) {
      ($user,$pass) = split(/:/, $url->userinfo());
    }

    # Parse URL
		my $db = $url->path();
		$db =~ s/^\///;
    my $dbi_string;
    if('postgres' eq $url->protocol()) {
      $dbi_string = sprintf('dbi:Pg:dbname=%s;host=%s;port=%s', $db, $url->host(), $url->port());
    }
    elsif('sqlite' eq $url->protocol()) {
      $dbi_string = 'dbi:SQLite:'.$db;
    }
    else {
      die "Unsupported URL scheme ".$url->protocol();
    }

    push(@dbargs, $dbi_string);
		push(@dbargs, $user) if $user;
    push(@dbargs, $pass) if $pass;
  }
  # Check for DBI if we have been given a full string
  elsif(exists $ENV{DBI}) {
    push(@dbargs, $ENV{DBI});
  }
  # Finally if DEV is set create the local SQLite DB called test.db
  elsif(exists $ENV{DEV}) {
    push(@dbargs, 'dbi:SQLite:test.db');
  }
  else {
    die "Please set the URI via one of the mechanisms"
  }

  return @dbargs;
}

1;