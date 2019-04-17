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
package Refget::Schema::ResultSet::Seq;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Refget::Util qw/trunc512_digest vmc_to_trunc512 detect_algorithm allowed_algorithm/;
use Digest::MD5 qw/md5_hex/;

sub create_seq {
  my ($self, $seq_hash, $molecule_type_obj, $release_obj) = @_;
  my $hash = trunc512_digest($seq_hash->{sequence});
  my $md5 = md5_hex($seq_hash->{sequence});
  my $length = length($seq_hash->{sequence});
  my $is_circular = $seq_hash->{circular};
  my $seq_obj = $self->find_or_new(
    {md5 => $md5, size => $length, trunc512 => $hash, circular => $is_circular},
    {key => 'seq_trunc512_uniq'}
  );
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
  my ($self, $id, $checksum_algorithm, $full_object) = @_;
  $checksum_algorithm //= detect_algorithm($id);
  #Convert from VMC to trunc512 if required
  if(defined $checksum_algorithm && $checksum_algorithm eq 'vmcdigest') {
    $checksum_algorithm = 'trunc512';
    $id = vmc_to_trunc512($id);
  }
  return undef unless allowed_algorithm($checksum_algorithm);
  my $options = {
    prefetch => 'molecules'
  };
  $options->{columns} = [qw/seq_id md5 trunc512 size circular/];
  # Case insensitive search by lowercase
  return $self->find({
    $checksum_algorithm => lc($id)
  },
  $options);
}

1;