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
package Refget::Schema::Result::RawSeq;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers;

__PACKAGE__->table('chunked_raw_seq');
__PACKAGE__->add_columns(
  checksum =>{
    data_type => 'char',
		size      => 48,
		is_nullable => 0,
	},
	seq =>{
		data_type => 'longtext',
		is_nullable => 0,
	},
	offset =>{
		data_type => 'int',
		is_nullable => 0,
    size      => 11,
    is_numeric => 1,
	},
	block =>{
		data_type => 'int',
		is_nullable => 0,
    size      => 11,
    is_numeric => 1,
	},
	length =>{
		data_type => 'int',
		is_nullable => 0,
    size      => 11,
    is_numeric => 1,
	},
);

__PACKAGE__->set_primary_key('checksum', 'offset');

1;
