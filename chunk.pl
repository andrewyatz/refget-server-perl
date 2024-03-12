#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw/ceil/;
use Test::More;

sub create_chunk_lookup {
  my ($seq, $power) = @_;
  my $length = length($seq);
  my $chunk = 1 << $power;
  my $iterations = ceil($length/$chunk);
  my $remainder = $length % $chunk;
  my $chunk_lookup = {};
  for(my $i = 0; $i < $iterations; $i++) {
    my $start = $chunk * $i;
    my $seq_chunk = substr($seq, $start, $chunk);
    my $chunk_length = length($seq_chunk);
    $chunk_lookup->{$i} = { seq => $seq_chunk, length => $chunk_length, start => $start, end => $start + $chunk_length };
  }
  return $chunk_lookup;
}

sub dumb_concat_substr {
  my ($chunk_lookup, $power, $substr_start, $substr_length) = @_;
  my $start_bin = $substr_start >> $power;
  my $end_bin = ($substr_start+$substr_length) >> $power;
  my $concat_string = q{};
  foreach my $bin ($start_bin .. $end_bin) {
    my $chunk = $chunk_lookup->{$bin};
    $concat_string .= $chunk->{seq};
  }
  my $modified_substr_start = $substr_start - ($start_bin << $power);
  my $subseq = substr($concat_string, $modified_substr_start, $substr_length);
  return $subseq;
}

sub concat_substr_onthefly {
  my ($chunk_lookup, $power, $substr_start, $substr_length) = @_;
  my $substr_end = $substr_start+$substr_length;
  my $start_bin = $substr_start >> $power;
  my $end_bin = ($substr_start+$substr_length) >> $power;
  my $concat_string = q{};
  foreach my $bin ($start_bin .. $end_bin) {
    my $chunk = $chunk_lookup->{$bin};
    my $virtual_start = $chunk->{start};
    my $virtual_end = $chunk->{end};
    # Calculate if we're in the first block (need to substring)
    my $diag = sprintf(
      'chunk:%d|v_start:%d|v_end:%d|substr_start:%d|substr_end:%d',
      $bin, $virtual_start, $virtual_end, $substr_start, $substr_end
    );
    # warn $diag;
    # warn $chunk->{seq};
    if($bin == $start_bin) {
      # warn 'if block 1';
      my $start = $substr_start - $virtual_start;
      my $length;
      if($substr_end > $virtual_end) {
        $length = $virtual_end - $substr_start;
      }
      else {
        $length = $substr_length;
      }
      # warn $start;
      # warn $length;
      $concat_string .= substr($chunk->{seq}, $start, $length);
    }
    # Caclulate if we're in the last block (need to substring)
    elsif($bin == $end_bin) {
      # warn 'if block 2';
      my $start = 0;
      my $length = $substr_end - $virtual_start;
      # warn $length;
      $concat_string .= substr($chunk->{seq}, $start, $length);
    }
    # Otherwise we must be in a block we need to subsume
    else {
      # warn 'else block 3';
      $concat_string .= $chunk->{seq};
    }
    # warn($concat_string);
    # print STDERR "\n";
  }
  return $concat_string
}

my $seq = 'ACG'x5;
my $power = 2;
my $substr_start = 2;
my $substr_length = 6;

my $chunk_lookup = create_chunk_lookup($seq, $power);
# use Data::Dumper; warn Dumper $chunk_lookup;
my $expected_subseq = 'GACGAC';
is(dumb_concat_substr($chunk_lookup, $power, $substr_start, $substr_length), $expected_subseq, 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, $substr_start, $substr_length), $expected_subseq, 'Concat on the fly');


is(dumb_concat_substr($chunk_lookup, $power, 3, 3), 'ACG', 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, 3, 3), 'ACG', 'Concat on the fly');

is(dumb_concat_substr($chunk_lookup, $power, 3, 5), 'ACGAC', 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, 3, 5), 'ACGAC', 'Concat on the fly');

is(dumb_concat_substr($chunk_lookup, $power, 0, 1), 'A', 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, 0, 1), 'A', 'Concat on the fly');

is(dumb_concat_substr($chunk_lookup, $power, 4, 1), 'C', 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, 4, 1), 'C', 'Concat on the fly');

is(dumb_concat_substr($chunk_lookup, $power, 3, 1), 'A', 'Dumb post concat substr');
is(concat_substr_onthefly($chunk_lookup, $power, 3, 1), 'A', 'Concat on the fly');



done_testing();