package Fastadb::Util;

use strict;
use warnings;

use Digest::SHA qw/sha512_hex sha512/;
use MIME::Base64 qw/encode_base64url decode_base64url/;

use Carp qw/confess/;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/
  trunc512_digest vmc_digest
  vmc_to_trunc512 trunc512_to_vmc
/;

sub trunc512_digest {
	my ($sequence, $digest_size) = @_;
	$digest_size //= 24;
	my $digest = sha512_hex($sequence);
	my $substring = substr($digest, 0, $digest_size*2);
	return $substring;
}

sub vmc_digest {
	my ($sequence, $digest_size) = @_;
	$digest_size //= 24;
	if(($digest_size % 3) != 0) {
		confess "Digest size must be a multiple of 3 to avoid padded digests";
	}
	my $digest = sha512($sequence);
	return _vmc_bytes($digest, $digest_size);
}

sub _vmc_bytes {
	my ($bytes, $digest_size) = @_;
	my $base64 = encode_base64url($bytes);
	my $substr_offset = int($digest_size/3)*4;
	my $vmc = substr($base64, 0, $substr_offset);
	return "VMC:GS_${vmc}";
}

sub vmc_to_trunc512 {
	my ($vmc) = @_;
	my ($base64) = $vmc =~ /VMC:GS_(.+)/;
	my $digest = unpack("H*", decode_base64url($base64));
	return $digest;
}

sub trunc512_to_vmc {
	my ($trunc_digest) = @_;
	my $digest_length = length($trunc_digest)/2;
	my $digest = pack("H*", $trunc_digest);
	return _vmc_bytes($digest, $digest_length);
}

1;