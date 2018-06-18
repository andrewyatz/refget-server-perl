package Fastadb::Schema::ResultSet::Seq;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Fastadb::Util qw/trunc512_digest vmc_to_trunc512/;

sub create_seq {
  my ($self, $seq_hash, $molecule_type_obj, $release_obj) = @_;
  my $hash = trunc512_digest($seq_hash->{sequence});
  my $seq_obj = $self->find_or_new({seq => $seq_hash->{sequence}, trunc512 => $hash},{key => 'seq_trunc512_uniq'});
  my $first_seen = 0;
  if(!$seq_obj->in_storage()) {
    $first_seen = 1;
    $seq_obj->insert();
  }
  my $molecule_obj = $seq_obj->find_or_create_related(
    'molecules',
    {
      id => $seq_hash->{id},
      first_seen => $first_seen,
      release => $release_obj,
      mol_type => $molecule_type_obj
    }
  );
  return $molecule_obj;
}

sub get_seq {
  my ($self, $id, $checksum_algorithm) = @_;
  $checksum_algorithm //= $self->detect_algorithm($id);
  #Convert from VMC to trunc512 if required
  if(defined $checksum_algorithm && $checksum_algorithm eq 'vmcdigest') {
    $checksum_algorithm = 'trunc512';
    $id = vmc_to_trunc512($id);
  }
  return undef unless $self->allowed_algorithm($checksum_algorithm);
  # Case insensitive search by lowercase
  return $self->find({
    $checksum_algorithm => lc($id)
  },
  {
    prefetch => 'molecules'
  });
}

sub detect_algorithm {
  my ($self, $key) = @_;
  return 'vmcdigest' if $key =~ /^VMC:GS_/;
  my $length = length($key);
  my $checksum_column = ($length == 32) ? 'md5'
                      : ($length == 48) ? 'trunc512'
                      : undef;
  return $checksum_column;
}

my %algorithms = map {$_ => 1} qw/md5 vmcdigest trunc512/;
sub allowed_algorithm {
  my ($self, $key) = @_;
  return 0 unless defined $key;
  return exists $algorithms{$key};
}

sub available_alorithms {
  my ($self) = @_;
  return keys %algorithms;
}

1;