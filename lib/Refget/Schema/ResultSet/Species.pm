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
package Refget::Schema::ResultSet::Species;

use strict;
use warnings;

use base qw/Refget::Schema::Abstract::Dict/;

sub type {
	my ($self) = @_;
	return 'species';
}

sub key {
	my ($self) = @_;
	return 'species_uniq';
}

sub create_entry {
	my ($self, $species, $assembly) = @_;
	my $obj = $self->find_or_create({$self->type() => $species, assembly => $assembly}, {key => $self->key()});
	return $obj;
}

1;