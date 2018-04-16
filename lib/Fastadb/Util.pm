package Fastadb::Util;

use strict;
use warnings;

use Digest::SHA qw/sha512_hex/;

sub reference_retrieval_checksum {
  my ($seq, $offset) = @_; # offset expressed in bytes
  $offset = 24 if ! defined $offset;
  my $digest = sha512_hex($sequence);
  my $substring = substr($digest, 0, $offset*2); #going into hex from bytes
  return $substring;
}

1;
