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
package Fastadb::Schema::Result::Release;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('release');

__PACKAGE__->add_columns(
	release_id =>{
		accessor  => 'release',
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	release =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
	},
	division_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_numeric => 1,
	},
	species_id  =>{
		data_type   => 'integer',
		size      => 16,
    is_nullable => 0,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(release_uniq => [qw/release division_id species_id/]);

__PACKAGE__->set_primary_key('release_id');

__PACKAGE__->belongs_to(species => 'Fastadb::Schema::Result::Species', 'species_id');
__PACKAGE__->belongs_to(division => 'Fastadb::Schema::Result::Division', 'division_id');
__PACKAGE__->has_many(molecule => 'Fastadb::Schema::Result::Molecule', 'release_id');

1;