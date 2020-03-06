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
use Test::More;

use strict;
use warnings;
use Refget::ServiceInfo;
use Test::Differences qw/eq_or_diff/;
use Mojo::JSON qw/true encode_json/;

my $service_info = Refget::ServiceInfo->new();
my $expected = {
  description => 'Reference implementation of the refget protocol',
  environment => 'dev',
  id => 'org.ga4gh.refget',
  name => 'Refget reference implementation',
  organization => {
    name => 'GA4GH',
    url => 'https://ga4gh.org'
  },
  type => {
    artifact => 'refget',
    group => 'ga4gh',
    version => '2.0.0'
  },
  refget => {
    algorithms => [qw/ga4gh md5 trunc512/],
    subsequence_limit => undef,
    circular_supported => true(),
  }
};

eq_or_diff($service_info->HASH(), $expected, 'Checking service info no customisation');

my $custom_si = Refget::ServiceInfo->build_from_config({
  organization => {
    name => 'Wibble', url => 'https://example.org'
  },
  documentationUrl => 'https://docs.example.org'
});

{
  my $custom_expected = { %{ $expected } };
  $custom_expected->{organization} = {
    name => 'Wibble', url => 'https://example.org'
  };
  $custom_expected->{documentationUrl} = 'https://docs.example.org';

  eq_or_diff($custom_si->HASH(), $custom_expected, 'Checking service info no customisation');
}

done_testing();
