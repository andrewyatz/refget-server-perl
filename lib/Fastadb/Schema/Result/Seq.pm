package Fastadb::Schema::Result::Seq;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Digest::MD5 qw/md5_hex/;
use Digest::SHA qw/sha512_hex sha256_hex sha1_hex/;
use Class::Method::Modifiers;

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
	sha1 =>{
		data_type => 'char',
		size      => 40,
		is_nullable => 0,
	},
	sha256 =>{
		data_type => 'char',
		size      => 64,
		is_nullable => 0,
	},
	sha512 =>{
		data_type => 'char',
		size      => 128,
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
  seq_sha256_uniq => [qw/sha256/]
);

__PACKAGE__->set_primary_key('seq_id');

__PACKAGE__->has_many(molecules => 'Fastadb::Schema::Result::Molecule', 'seq_id');

sub sqlt_deploy_hook {
	my ($self, $sqlt_table) = @_;
	$sqlt_table->add_index(name => 'md5_idx', fields => ['md5']);
	$sqlt_table->add_index(name => 'sha1_idx', fields => ['sha1']);
	$sqlt_table->add_index(name => 'sha512_idx', fields => ['sha512']);
	return $sqlt_table;
}

sub new {
	my ( $class, $attrs ) = @_;
	$attrs->{md5} = md5_hex($attrs->{seq}) unless defined $attrs->{md5};
	$attrs->{sha1} = sha1_hex($attrs->{seq}) unless defined $attrs->{sha1};
	$attrs->{sha256} = sha256_hex($attrs->{seq}) unless defined $attrs->{sha256};
	$attrs->{sha512} = sha512_hex($attrs->{seq}) unless defined $attrs->{sha512};
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
		$self->sha1(sha1_hex($value));
		$self->sha256(sha256_hex($value));
		$self->sha512(sha512_hex($value));
		$self->size(length($value));
	}
	$self->$orig(@_);
};

sub default_checksum {
	my ($self) = @_;
	return $self->sha256();
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

1;