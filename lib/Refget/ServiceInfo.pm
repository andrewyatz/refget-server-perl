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
package Refget::ServiceInfo;

use Moose;
use Mojo::JSON qw/true/;
use Refget::App;
use Refget::Util qw/available_algorithms/;

use Moose::Util::TypeConstraints qw/enum/;
enum ServiceInfoEnvs => [qw/prod test dev staging/];

has 'id' => ( isa => 'Str', is => 'ro', default => 'org.ga4gh.refget' );
has 'name' => ( isa => 'Str', is => 'ro', default => 'Refget reference implementation' );
has 'description' => ( isa => 'Str', is => 'ro', default => 'Reference implementation of the refget protocol' );
has 'version' => ( isa => 'Str', is => 'ro', default => sub { $Refget::App::VERSION } );

has 'contactUrl'=> ( isa => 'Maybe[Str]', is => 'ro', required => 0 );
has 'documentationUrl' => ( isa => 'Maybe[Str]', is => 'ro', required => 0 );
has 'createdAt' => ( isa => 'Maybe[Str]', is => 'ro', required => 0 );
has 'updatedAt' => ( isa => 'Maybe[Str]', is => 'ro', required => 0 );
has 'environment' => ( isa => 'ServiceInfoEnvs', is => 'ro', default => 'dev');

has 'type' => ( isa => 'HashRef', is => 'ro', builder => '_build_type' );
has 'organization' => ( isa => 'HashRef', is => 'ro', builder => '_build_organization' );
has 'refget' => ( isa => 'HashRef', is => 'ro', builder => '_build_refget' );

sub build_from_config {
  my ($class, $config_hash) = @_;
  $config_hash //= {};
  return $class->new(%{$config_hash});
}

sub HASH {
  my ($self) = @_;
  my $hash = {
    description => $self->description(),
    environment => $self->environment(),
    id => $self->id(),
    name => $self->name(),
    version => $self->version(),
  };

  $hash->{contactUrl} = $self->contactUrl() if defined $self->contactUrl();
  $hash->{documentationUrl} = $self->documentationUrl() if defined $self->documentationUrl();
  $hash->{createdAt} = $self->createdAt() if defined $self->createdAt();
  $hash->{updatedAt} = $self->updatedAt() if defined $self->updatedAt();

  $hash->{organization} = { %{ $self->organization() } };
  $hash->{type} = { %{ $self->type() } };
  $hash->{refget} = { %{ $self->refget() } };

  return $hash;
}

sub _build_refget {
  my ($self) = @_;
  return {
    circular_supported => true(),
    subsequence_limit => undef,
    algorithms => [sort {$a cmp $b} available_algorithms()],
  };
}

sub _build_organization {
  my ($self) = @_;
  return {
    name => "GA4GH",
    url => "https://ga4gh.org"
  };
}

sub _build_type {
  my ($self) = @_;
  return {
    group => 'ga4gh',
    artifact => 'refget',
    version => $Refget::App::API_VERSION
  };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
