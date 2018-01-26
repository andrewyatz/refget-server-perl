package Fastadb::Fmt::IO;
use Moose::Role;

has 'file' => (isa => 'Str', is => 'ro');

has 'fh' => (isa => 'FileHandle', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  my $fh;
  if($self->file() =~ /\.gz$/) {
    open $fh, '-|', 'gzip -cd '.$self->file() or die "Could not open file: $!";
  }
  else {
    open $fh, '<', $self->file() or die "Could not open file: $!";
  }
  $self->_opened_file(1);
  return $fh;
});

has '_opened_file' => (isa => 'Bool', is => 'rw', default => 0);

sub iterate {
  my ($self, $callback) = @_;
  my $fh = $self->fh();
  while(my $line = <$fh>) {
    chomp $line;
    my $continue = $callback->($line);
    if(!$continue) {
      last;
    }
  }
  return;
}

sub DEMOLISH {
  my ($self) = @_;
  if($self->_opened_file()) {
    close $self->fh();
  }
  return;
}

1;
