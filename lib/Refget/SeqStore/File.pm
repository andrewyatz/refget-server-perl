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
package Refget::SeqStore::File;

use Moose;
use File::Spec;
use File::Path qw/make_path/;

use namespace::autoclean;

with 'Refget::SeqStore::Base';

has 'root_dir' => (isa => 'Str', is => 'ro', required => 1);
has 'skip_if_found' => (isa => 'Bool', is => 'ro', required => 1, default => 1);
has 'file_mode' => ( isa => 'Str', is => 'ro', required => 1, default => '0644');

# Store a sequence
sub _store {
  my ($self, $checksum, $sequence) = @_;
  my $path = $self->_create_path($checksum);
  if(-f $path) {
    return $path if $self->skip_if_found();
    confess "Cannot continue to import. Path already exists at '${path}'";
  }
	my ($volume, $dir, $file) = File::Spec->splitpath($path);
	if(!-d $dir) {
		make_path($dir) or confess "Could not create directory ";
	}
  open my $fh, '>', $path or confess "Cannot open '${path}' for writing: $!";
  print $fh $sequence or confess "Cannot write sequence to '${path}': $!";
  close $fh or confess "Cannot close filehandle: $!";
  my $mode = $self->file_mode();
  chmod(oct($mode), $path) or confess "Cannot change '${path}' to permissions '${mode}': $!";
  return $path;
}

sub _sub_seq {
  my ($self, $checksum, $start, $length) = @_;
  return q{} if $length == 0; # return a blank string if we were asked for a 0 length string
  my $path = $self->_create_path($checksum);
  open my $fh, '<', $path or confess "Cannot open '${path}' for reading: $!";
  seek($fh, $start, 0) or confess "Cannot seek to position ${start} in file '${path}': $!";
  my $sequence = q{};
  read($fh, $sequence, $length) or confess "Cannot read sequence of length $length in file '${path}': $!";
  close $fh or confess "Cannot close filehandle: $!";
  return $sequence;
}

sub _create_path {
  my ($self, $checksum) = @_;
  my ($part_one, $part_two) = (substr($checksum, 0, 2), substr($checksum, 2, 2));
  return File::Spec->catfile($self->root_dir(), $part_one, $part_two, $checksum);
}

__PACKAGE__->meta->make_immutable;

1;
