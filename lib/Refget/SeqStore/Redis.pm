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
package Refget::SeqStore::Redis;

use Moose;
use namespace::autoclean;
use Redis;

with 'Refget::SeqStore::Base';

# Pass redis_args with any options you would have given to the Redis module
has 'redis' => (isa => 'Any', is => 'ro', required => 1, lazy => 1, builder => 'build_redis');
has 'redis_args' => (isa => 'HashRef', is => 'ro', required => 1, default => sub { {} });

sub build_redis {
  my ($self) = @_;
  return Redis->new(%{$self->redis_args()});
}

sub _store {
	my ($self, $checksum, $sequence) = @_;
  return $self->redis()->set($checksum, $sequence);
}

sub _sub_seq {
	my ($self, $checksum, $start, $length) = @_;
	return $self->redis()->getrange($checksum, $start, ($start+$length));
}

__PACKAGE__->meta->make_immutable;

1;
