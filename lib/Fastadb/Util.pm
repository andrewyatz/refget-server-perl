package Fastadb::Util;

use strict;
use warnings;

use utf8;
use Digest::SHA qw/sha512/;
use MIME::Base64 qw/encode_base64url/;
use Carp qw/confess/;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(vmc_digest);

sub vmc_digest {
  my ($sequence) = @_;
  confess "Given an undefined string to digest into VMC" if ! defined $sequence;
  if(! utf8::is_utf8($sequence)) {
    utf8::encode($sequence);
  }
  my $digest = sha512($sequence);
  my $substring = substr($digest, 0, 24);
  my $hex = encode_base64url($substring);
  return "VMC:GS_${hex}";
}

1;