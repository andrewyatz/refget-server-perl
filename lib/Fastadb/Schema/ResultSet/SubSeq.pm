package Fastadb::Schema::ResultSet::SubSeq;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub get_seq {
  my ($self, $seq_obj, $start, $end) = @_;
  $start = 0 if ! defined $start;
  $end = $seq_obj->size() if ! defined $end;
  my $length = $end - $start;
  my $rs = $self->search( {}, { bind => [ $start, $length, $seq_obj->sha1() ] } );
  return $rs->next()->seq();
}

1;