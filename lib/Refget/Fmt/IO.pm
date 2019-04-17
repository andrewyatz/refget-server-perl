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
package Refget::Fmt::IO;
use Moose::Role;

has 'file' => (isa => 'Str', is => 'ro');

has 'fh' => (isa => 'FileHandle', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  my $fh;
  if($self->file() =~ /\.gz$/) {
    open $fh, '-|', 'gzip -cd '.$self->file() or die "Could not open file: $!";
  }
  else {
    open $fh, '<', $self->file() or die "Could not open file: $!";
  }
  $self->_opened_file(1);
  return $fh;
});

has '_opened_file' => (isa => 'Bool', is => 'rw', default => 0);

sub iterate {
  my ($self, $callback) = @_;
  my $fh = $self->fh();
  while(my $line = <$fh>) {
    chomp $line;
    my $continue = $callback->($line);
    if(!$continue) {
      last;
    }
  }
  return;
}

sub DEMOLISH {
  my ($self) = @_;
  if($self->_opened_file()) {
    close $self->fh();
  }
  return;
}

1;
