package Fastadb::Schema::ResultSet::SubSeq;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub get_seq {
  my ($self, $seq_obj, $start, $end) = @_;

  my $seq_size = $seq_obj->size();
  $start = 0 if ! defined $start;
  $end = $seq_size if ! defined $end;

  my $sequence;
  # We are in a circular sequence call
  if($start > $end && $seq_obj->circular()) {
    my $subseq = $self->_sub_seq($start, ($seq_size-$start), $seq_obj);
		$subseq .= $self->_sub_seq(0, $end, $seq_obj);
		$sequence = $subseq;
  }
  else {
    my $length = $end - $start;
    $sequence = $self->_sub_seq($start, $length, $seq_obj);
  }

  return $sequence;
}

sub _sub_seq {
  my ($self, $start, $length, $seq_obj) = @_;
  my $rs = $self->search( {}, { bind => [ $start, $length, $seq_obj->sha1() ] } );
  return $rs->next()->seq();
}

1;