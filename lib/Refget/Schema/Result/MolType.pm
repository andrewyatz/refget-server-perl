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
package Refget::Schema::Result::MolType;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('mol_type');

__PACKAGE__->add_columns(
	mol_type_id =>{
		data_type => 'integer',
		size      => 16,
		is_nullable => 0,
		is_auto_increment => 1,
		is_numeric => 1,
	},
	type =>{
		data_type => 'varchar',
		size      => 256,
		is_nullable => 0,
	},
);

__PACKAGE__->add_unique_constraint(mol_type_uniq => [qw/type/]);

__PACKAGE__->set_primary_key('mol_type_id');

__PACKAGE__->has_many(seqs => 'Refget::Schema::Result::Molecule', 'mol_type_id');

1;