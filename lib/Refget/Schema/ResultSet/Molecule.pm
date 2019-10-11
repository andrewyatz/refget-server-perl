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
package Refget::Schema::ResultSet::Molecule;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Refget::Util qw/trunc512_digest ga4gh_to_trunc512 detect_algorithm allowed_algorithm/;
use Digest::MD5 qw/md5_hex/;

# get a result set which represents all known molecules for the given sequence checksum identifier
sub get_molecules {
  my ($self, $id, $checksum_algorithm) = @_;
  $checksum_algorithm //= detect_algorithm($id);
  #Convert from ga4gh to trunc512 if required
  if(defined $checksum_algorithm && $checksum_algorithm eq 'ga4ghdigest') {
    $checksum_algorithm = 'trunc512';
    $id = ga4gh_to_trunc512($id);
  }
  return undef unless allowed_algorithm($checksum_algorithm);
  my $options = {
    prefetch => 'seq'
  };
  $options->{columns} = [qw/seq_id md5 trunc512 size circular/];
  # Case insensitive search by lowercase

  return $self->search(
    {
      "seq.${checksum_algorithm}" => $id },
    {
      join => ['seq', 'source', 'synonyms' ],
      prefetch => [qw/seq source/, {synonyms => 'source'}],
    }
  );

  return $self->find({
    $checksum_algorithm => lc($id)
  },
  $options);
}

1;