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
package Refget::App::Controller::Metadata;

use Mojo::Base 'Mojolicious::Controller';
use Refget::Util qw/allowed_algorithm/;

sub id {
	my ($self) = @_;
	my $id = $self->param('id');
	my $no_full_object = 0;
	my $seq = $self->db()->resultset('Seq')->get_seq($id);

	if(!$seq) {
		return $self->render(text => 'Not Found', status => 404);
	}

  # Need to use unique indexing here because the same ID can be inserted because of different releases
  my $alias_lookup = {};

	my @aliases = ({ alias => $seq->vmcdigest(), naming_authority => 'vmc' },);
	my $molecules = $seq->molecules();
	foreach my $m (sort {$a->id() cmp $b->id() } $molecules->all()) {
    my $id = $m->id();
    my $source = $m->source()->source();
    if(! $alias_lookup->{$source}->{$id} ) {
		  push(@aliases, { alias => $id, naming_authority => $source });
      $alias_lookup->{$source}->{$id} = 1;
    }
		my $synonyms = $m->synonyms();
		if($synonyms != 0) {
			foreach my $s ($synonyms->next()) {
        my $synonym = $s->synonym();
        my $authority = $s->source()->source();
        if(! $alias_lookup->{$authority}->{$synonym}) {
				  push(@aliases, { alias => $synonym, naming_authority => $authority });
          $alias_lookup->{$authority}->{$synonym} = 1;
        }
			}
		}
	}

	$self->respond_to(
		json => {
			json => {
				metadata => {
					length => $seq->size(),
					md5 => $seq->md5,
					trunc512 => $seq->trunc512,
					aliases => \@aliases
				}
			}
		},
		any  => {data => 'Not Acceptable', status => 406}
	);
}

1;