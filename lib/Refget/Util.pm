# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
package Refget::Util;

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
	detect_algorithm allowed_algorithm available_algorithms
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

sub detect_algorithm {
  my ($key) = @_;
  return 'vmcdigest' if $key =~ /^VMC:GS_/;
  my $length = length($key);
  my $checksum_column = ($length == 32) ? 'md5'
                      : ($length == 48) ? 'trunc512'
                      : undef;
  return $checksum_column;
}

my %algorithms = map {$_ => 1} qw/md5 trunc512 vmcdigest/;
sub allowed_algorithm {
  my ($key) = @_;
  return 0 unless defined $key;
  return exists $algorithms{$key};
}

sub available_algorithms {
  return keys %algorithms;
}

1;