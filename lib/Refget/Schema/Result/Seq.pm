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
package Refget::Schema::Result::Seq;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;
use Refget::Util qw/trunc512_to_vmc/;

__PACKAGE__->table('seq');

__PACKAGE__->add_columns(
	seq_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
    is_numeric => 1,
	},
	md5  =>{
		data_type => 'char',
		size      => 32,
		is_nullable => 0,
	},
	trunc512 =>{
		data_type => 'char',
		size      => 48,
		is_nullable => 0,
	},
  size =>{
    data_type => 'integer',
    size      => 11,
    is_nullable => 0,
    is_numeric => 1,
  },
  circular =>{
		data_type   => 'integer',
    is_boolean  => 1,
		false_is    => ['0','-1'],
		is_nullable => 0,
		default_value => 0,
	},
);

__PACKAGE__->add_unique_constraint(
  seq_trunc512_uniq => [qw/trunc512/]
);

__PACKAGE__->set_primary_key('seq_id');

__PACKAGE__->has_many(molecules => 'Refget::Schema::Result::Molecule', 'seq_id');

sub sqlt_deploy_hook {
	my ($self, $sqlt_table) = @_;
	$sqlt_table->add_index(name => 'md5_idx', fields => ['md5']);
	$sqlt_table->add_index(name => 'trunc512_idx', fields => ['trunc512']);
	return $sqlt_table;
}

sub new {
	my ( $class, $attrs ) = @_;
	# force lowercase for later lookup
	$attrs->{md5} = lc($attrs->{md5});
	$attrs->{trunc512} = lc($attrs->{trunc512});
	$attrs->{circular} = 0 unless defined $attrs->{circular};
	my $new = $class->next::method($attrs);
	return $new;
}

sub default_checksum {
	my ($self) = @_;
	return $self->trunc512();
}

sub vmcdigest {
	my ($self) = @_;
	my $trunc512 = $self->trunc512();
	return trunc512_to_vmc($trunc512);
}

1;