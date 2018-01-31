package Fastadb::Fmt::Fasta;
use Moose;
use namespace::autoclean;

has 'id' => (isa => 'Str', is => 'rw', clearer => 'clear_id');
has 'additional' => (isa => 'Str', is => 'rw', clearer => 'clear_additional', default => q{});
has 'type' => (isa => 'Str', is => 'ro', required => 1);

with 'Fastadb::Fmt::IO';

around 'iterate' => sub {
  my ($orig, $self) = @_;
  my $id;
  my $additional = q{};
  my $sequence = q{};
  my $past_first_line = 0;
  $self->$orig(sub {
    my ($line) = @_;
    # Look for header lines
    if($line =~ /^>([a-z0-9_.-]+)\s?(?:(.+))?/i) {
      my $local_id = $1;
      my $local_additional = $2 || q{};
      if(! defined $id && $past_first_line) {
        $id = $self->id();
        $self->id($local_id);
        $additional = $self->additional();
        $self->additional($local_additional);
        return 0; # break iterating. Hit an ID and we were in a record
      }
      $self->id($local_id);
      $self->additional($local_additional);
    }
    else {
      if($line ne q{}) {
        $line =~ s/\s+//g;
        $sequence .= uc($line);
      }
    }
    $past_first_line = 1; # need to set otherwise we bail too early
    return 1; # continue iterating. Not at the end of a record yet
  });

  # Run if we had no ID (so didn't hit another >) but had one in the object (must be last FASTA record)
  if(! $id && $self->id()) {
    $id = $self->id();
    $self->clear_id();
    $self->clear_additional();
  }

  # If ID was set then return
  if($id) {
    return { id => $id, sequence => $sequence, additional => $additional, type => $self->type() };
  }

  # Otherwise end iteration
  return;
};

__PACKAGE__->meta->make_immutable;

1;