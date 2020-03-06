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
use Refget::ServiceInfo;

sub ping {
  my ($self) = @_;
  $self->render(text => "Ping");
}

sub service {
  my ($self) = @_;
  my $service_info = Refget::ServiceInfo->build_from_config($self->config()->{service_info});
  $self->respond_to(
    json => { json => $service_info->HASH() },
    any  => {data => 'Not Acceptable', status => 406}
  );
}

1;