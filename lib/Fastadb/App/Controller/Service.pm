package Fastadb::App::Controller::Service;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/true/;

sub ping {
	my ($self) = @_;
	$self->render(text => "Ping");
}

sub service {
	my ($self) = @_;
  $self->respond_to(
    json => { json => {
      supported_api_versions => ['0.2'],
      circular_locations => true(),
      subsequence_limit => undef,
      algorithms => [qw/md5 trunc512 vmc/],
    }},
    any  => {data => 'Unsupported Media Type', status => 415}
  );
}

1;