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
package Fastadb::Schema::Result::Seq;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Digest::MD5 qw/md5_hex/;
use Class::Method::Modifiers;
use Fastadb::Util qw/trunc512_digest trunc512_to_vmc/;

__PACKAGE__->table('seq');

__PACKAGE__->add_columns(
	seq_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
    is_numeric => 1,
	},
	seq =>{
		data_type => 'text',
		is_nullable => 0,
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

__PACKAGE__->has_many(molecules => 'Fastadb::Schema::Result::Molecule', 'seq_id');

sub sqlt_deploy_hook {
	my ($self, $sqlt_table) = @_;
	$sqlt_table->add_index(name => 'md5_idx', fields => ['md5']);
	$sqlt_table->add_index(name => 'trunc512_idx', fields => ['trunc512']);
	return $sqlt_table;
}

sub new {
	my ( $class, $attrs ) = @_;
	$attrs->{md5} = md5_hex($attrs->{seq}) unless defined $attrs->{md5};
	$attrs->{trunc512} = trunc512_digest($attrs->{seq}) unless defined $attrs->{trunc512};
	# force lowercase for later lookup
	$attrs->{md5} = lc($attrs->{md5});
	$attrs->{trunc512} = lc($attrs->{trunc512});
	$attrs->{size} = length($attrs->{seq}) unless defined $attrs->{size};
	$attrs->{circular} = 0 unless defined $attrs->{circular};
	my $new = $class->next::method($attrs);
	return $new;
}

around seq => sub {
	my ($orig, $self) = (shift, shift);
	if (@_) {
		my $value = $_[0];
		$self->md5(md5_hex($value));
		$self->trunc512(trunc512_digest($value));
		$self->size(length($value));
	}
	$self->$orig(@_);
};

sub default_checksum {
	my ($self) = @_;
	return $self->trunc512();
}

sub get_seq {
	my ($self, $subseq_rs, $start, $end) = @_;
	return $subseq_rs->get_seq($self, $start, $end);
}

sub to_fasta {
	my ($self, $subseq_rs, $start, $end, $residues_per_line) = @_;
	$residues_per_line //= 60;
	my $seq = $self->get_seq($subseq_rs, $start, $end);
	$seq =~ s/(\w{$residues_per_line})/$1\n/g;
	my $id = $self->default_checksum();
	return ">${id}\n${seq}";
}

sub vmcdigest {
	my ($self) = @_;
	my $trunc512 = $self->trunc512();
	return trunc512_to_vmc($trunc512);
}

1;