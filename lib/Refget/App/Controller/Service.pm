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
package Refget::App::Controller::Service;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/true/;
use Refget::Util qw/available_algorithms/;

sub ping {
	my ($self) = @_;
	$self->render(text => "Ping");
}

sub service {
	my ($self) = @_;
  $self->respond_to(
    json => { json => {service => {
      supported_api_versions => ['1.0.0'],
      circular_supported => true(),
      subsequence_limit => undef,
      algorithms => [sort {$a cmp $b} available_algorithms()],
    }}},
    any  => {data => 'Not Acceptable', status => 406}
  );
}

1;