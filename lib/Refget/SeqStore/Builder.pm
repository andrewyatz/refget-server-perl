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
package Refget::SeqStore::Builder;

use Moose;
use namespace::autoclean;
use Class::Load qw/load_class/;
use Scalar::Util qw/reftype/;

has 'allowed' => (isa => 'HashRef', is => 'ro', required => 1, lazy => 1, builder => 'build_allowed');

# Main method to use. Give it the normal config hash and it will do the rest
sub build_from_config {
  my ($class, $hash) = @_;
  confess "No 'seq_store' key found in the given hash" unless exists $hash->{seq_store};
  confess "No 'seq_store_args' key found in the given hash" unless exists $hash->{seq_store_args};
  my $type = reftype($hash->{seq_store_args});
  $type //= q{}; # if it was a string this comes out as nothing.
  confess "'seq_store_args' was not a hash. Found '${type}''" if $type ne 'HASH';
  my $builder = $class->new();
  return $builder->build($hash->{seq_store}, $hash->{seq_store_args});
}

sub build_allowed {
  return { map {$_ => 1} qw/File DBIx Redis/ };
}

sub type_to_class {
  my ($self, $type) = @_;
  confess "Type '${type}' is not an allowed SeqStore implementation" if ! exists $self->allowed->{$type};
  my $seq_store_class = "Refget::SeqStore::${type}";
  load_class($seq_store_class);
}

sub build {
  my ($self, $type, $args) = @_;
  my $seq_store_class = $self->type_to_class($type);
  my $seq_store = $seq_store_class->new(%{$args});
  confess "Could not build SeqStore instance $seq_store_class" if ! defined $seq_store;
  return $seq_store;
}

__PACKAGE__->meta->make_immutable;

1;
