package Fastadb::App::Controller::Service;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/true/;
use Fastadb::Util qw/available_algorithms/;

sub ping {
	my ($self) = @_;
	$self->render(text => "Ping");
}

sub service {
	my ($self) = @_;
  $self->respond_to(
    json => { json => {service => {
      supported_api_versions => ['0.2'],
      circular_supported => true(),
      subsequence_limit => undef,
      algorithms => [sort {$a cmp $b} available_algorithms()],
    }}},
    any  => {data => 'Unsupported Media Type', status => 415}
  );
}

1;