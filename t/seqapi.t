use Test::More;

use strict;
use warnings;
use IO::Uncompress::Gunzip qw/gunzip $GunzipError/;
use IO::Compress::Gzip 'gzip';
use Mojo::JSON;

use Test::DBIx::Class {
  schema_class => 'Fastadb::Schema',
  resultsets => [ qw/SubSeq Seq MolType Release Molecule Division Species Synonym/ ],
};
use Test::Mojo;

isa_ok Schema, 'Fastadb::Schema'=> 'Got Correct Schema';
isa_ok ResultSet('Seq'), 'Fastadb::Schema::ResultSet::Seq'=> 'Got the right Seq';

my ($mol_type, $division, $species, $release);
fixtures_ok sub {
	$mol_type = MolType->create({type => 'protein'});
	$division = Division->create({division => 'ensembl'});
	$species = Species->create({species => 'yeast', assembly => 'R64-1-1'});
	$release = Release->create({release => 91, species => $species, division => $division});
};

my $raw_seq_one = 'MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSGK';
fixtures_ok sub {
  my $seq = Seq->create({
    seq => $raw_seq_one,
    md5 => 'b6517aa110cc10776af5c368c5342f95',
    trunc512 => '0f1c17124a6adb8543a30e86bc2191cb1a16bc2931a56ba8',
    # vmcdigest => 'VMC:GS_DxwXEkpq24VDow6GvCGRyxoWvCkxpWuo',
    size => 61,
  });
  my $seq2 = Seq->create({
    seq => 'MSSPTPPGGQRTLQKRKQGSSQKVAASAPKKNTNSNNSILKIYSDEATGLRVDPLVVLFLAVGFIFSVVALHVISKVAGKLF',
    md5 => 'c8e76de5f86131da26e8dd163658290d',
    trunc512 => '3ee63c430df30d169a3c79f81158abcf6629599c655dc6d8',
    # vmcdigest => 'VMC:GS_PuY8Qw3zDRaaPHn4EVirz2YpWZxlXcbY',
    size => 82,
  });
  my $seq3 = Seq->create({
    seq => 'ABCDEFGH',
    md5 => '4783e784b4fa2fba9e4d6502dbc64f8f',
    trunc512 => '8b66b893918da31d49763a6c420b4cad75a2663682bb317d',
    size => 8,
    circular => 1
  });

  Molecule->create({
    id => 'YHR055C',
    first_seen => 1,
    seq => $seq,
    release => $release,
    mol_type => $mol_type,
  });
  Molecule->create({
    id => 'YER087C-B',
    first_seen => 1,
    seq => $seq2,
    release => $release,
    mol_type => $mol_type,
    synonyms => [ { synonym => 'synonym'} ],
  });
  Molecule->create({
    id => 'Circ',
    first_seen => 1,
    seq => $seq3,
    release => $release,
    mol_type => $mol_type,
  });

},'Installed fixtures';

# Set the application with the right schema. SQLite memory databases are a per driver thing
my $t = Test::Mojo->new('Fastadb::App');
$t->app->schema(Schema);


# Disable GZipping content unless boolean says otherwise. Mojo does this automatically during requests
my $disable_gzip_accept_encoding = 1;
$t->ua->on(start => sub {
  my ($ua, $tx) = @_;
  $tx->req->headers->remove('Accept-Encoding') if $disable_gzip_accept_encoding;
});

my $text_content_type = 'text/vnd.ga4gh.seq.v1.0.0+plain; charset=us-ascii';

# Test service level endpoints
$t->get_ok('/ping', { Accept => 'plain/text'})
  ->status_is(200)
  ->content_is('Ping');

$t->get_ok('/service-info', { Accept => 'application/json'})
  ->status_is(200)
  ->json_is({
    supported_api_versions => ['0.1'],
    circular_locations => Mojo::JSON::true()
  });

# Start testing the major endpoints

my $md5 = 'b6517aa110cc10776af5c368c5342f95';
my $seq_obj = Seq->get_seq($md5, 'md5');
my $raw_seq = $seq_obj->get_seq(SubSeq);
is($raw_seq, $raw_seq_one, 'Making sure sequence from API matches expected');

# Being used for the next 5 or so tests
my $basic_check_sub = sub {
  my ($checksum, $checksum_type) = @_;
  $t->get_ok('/sequence/'.$checksum => { Accept => 'text/plain'})
    ->status_is(200, 'Testing HTTP status code for '.$checksum_type)
    ->content_is($raw_seq, "Checking the retrieved sequence is as expected for checksum ${checksum_type}");
};

foreach my $m (qw/md5 trunc512/) {
  my $digest = $seq_obj->$m(); #meta method call for digest
  $basic_check_sub->($digest, $m);
  # Upper case vs lower case
  $basic_check_sub->(uc($digest), "uppercase $m");
  $basic_check_sub->(lc($digest), "lowercase $m");
}
$basic_check_sub->($seq_obj->vmcdigest(), "vmcdigest");

# Just force vmcdigest checks
my $vmc_digest = 'VMC:GS_DxwXEkpq24VDow6GvCGRyxoWvCkxpWuo';
$t->get_ok('/sequence/'.$vmc_digest => { Accept => 'text/plain'})
    ->status_is(200)
    ->content_is($raw_seq);

# Trying Range requests
my $basic_url = '/sequence/'.$md5;

# Trying Range requests
$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=58-60'})
  ->status_is(206)
  ->header_is('Accept-Ranges', 'none')
  ->content_is('SGK');

$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=0-60'})
  ->status_is(200)
  ->content_is($raw_seq);

$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=58'})
  ->status_is(400);
$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=0-bogus'})
  ->status_is(400);
$t->get_ok($basic_url.'?start=0&end=1' => { Accept => 'text/plain', Range => 'bytes=0-2'})
  ->status_is(400)
  ->content_is('Invalid Input');

# Good substring request
$t->get_ok("/sequence/${md5}?start=0&end=1" => { Accept => 'text/plain' })
  ->status_is(200)
  ->content_is('M');

# Circular Genomes request; seq is
# 01234567
# ABCDEFGH
# 12345678
# Circular range of 6-3 should be: GHABC
my $circ_digest = '8b66b893918da31d49763a6c420b4cad75a2663682bb317d';
$t->get_ok("/sequence/${circ_digest}?start=6&end=3", => {Accept => 'text/plain' })
  ->status_is(200, 'Successful circular request')
  ->content_is('GHABC');
$t->get_ok("/sequence/${md5}?start=6&end=3", => {Accept => 'text/plain' })
  ->status_is(416, 'Cannot request circular from a non-circular sequence');

# Substring with start but no end
$t->get_ok("/sequence/${md5}?start=58" => { Accept => 'text/plain' })
  ->status_is(200)
  ->content_is('SGK');

# Bad start/end request
$t->get_ok("/sequence/${md5}?start=10&end=1" => { Accept => 'text/plain' })
  ->status_is(416)
  ->content_is('Range Not Satisfiable');

# Bad start/end request
$t->get_ok("/sequence/${md5}?start=1000" => { Accept => 'text/plain' })
  ->status_is(400)
  ->content_is('Invalid Range');

# No content specified so return text/plain by default
$t->get_ok($basic_url)
  ->status_is(200)
  ->content_type_is($text_content_type);

# Bad formats. Say unsupported if a client was specific about the format
$t->get_ok($basic_url => { Accept => 'text/html' })
  ->status_is(415)
  ->content_is('Unsupported Media Type');

# FASTA now
$t->get_ok($basic_url => { Accept => 'text/x-fasta' })
  ->status_is(200)
  ->content_is(">0f1c17124a6adb8543a30e86bc2191cb1a16bc2931a56ba8
MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSG
K");

# Trying head requests now
$t->head_ok($basic_url => { Accept => 'text/plain'})
  ->status_is(200)
  ->content_type_is($text_content_type)
  ->header_is('Content-Length', '61', 'Content-Length is the same as sequence length');

# Turn on Gzip and ensure we get content-length of the compressed content
$disable_gzip_accept_encoding = 0;
$t->head_ok($basic_url => { Accept => 'text/plain', 'TE' => 'gzip'})
  ->status_is(200, 'Accept-Encoding does not affect URL success')
  ->content_type_is($text_content_type, 'Content-Type remains text/plain with TE: gzip')
  ->header_is('Transfer-Encoding', 'chunked, gzip', 'Transfer-Encoding is gzip')
  ->header_is('Content-Length', '69', 'Content-Length of Accept-Encoding is set to 69');

#Test Accept-Encoding
$t->head_ok($basic_url => { Accept => 'text/plain', 'Accept-Encoding' => 'gzip'})
  ->status_is(200, 'Accept-Encoding does not affect URL success')
  ->content_type_is($text_content_type, 'Content-Type remains text/plain with Accept-Encoding gzip')
  ->header_is('Vary', 'Accept-Encoding', 'Transfer-Encoding is gzip')
  ->header_is('Content-Length', '61', 'Content-Length of Accept-Encoding is set to 61 (because Mojo decompressed it)');

$disable_gzip_accept_encoding = 1;

# Switching and testing content types are correct
$t->head_ok($basic_url => { Accept => $text_content_type})
  ->status_is(200)
  ->content_type_is($text_content_type);

# Bogus sequence
$t->get_ok('/sequence/bogus' => { Accept => 'text/plain' })
  ->status_is(404)
  ->content_is('Not Found');

#GZipped response testing
$disable_gzip_accept_encoding = 0;
$t->get_ok($basic_url => { Accept => 'text/plain', 'TE' => 'gzip' })
  ->status_is(200);
my $compressed_resp = $t->tx->res->body;
gunzip \$compressed_resp => \my $uncompressed_output or fail( "Gunzip failed: $GunzipError");
is($raw_seq, $uncompressed_output, 'Content was compressed; uncompressing and we get sequence back');
$disable_gzip_accept_encoding = 1;

# Batch retrieval
$t->post_ok('/batch/sequence'
  => { Accept => 'application/json' }
  => form => {
    id => ['0f1c17124a6adb8543a30e86bc2191cb1a16bc2931a56ba8', '3ee63c430df30d169a3c79f81158abcf6629599c655dc6d8', 'bogus']
  })
  ->status_is(200)
  ->json_is([
    {
      id => '0f1c17124a6adb8543a30e86bc2191cb1a16bc2931a56ba8',
      seq => 'MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSGK',
      trunc512 => '0f1c17124a6adb8543a30e86bc2191cb1a16bc2931a56ba8',
      found => 1,
    },
    {
      id => '3ee63c430df30d169a3c79f81158abcf6629599c655dc6d8',
      seq => 'MSSPTPPGGQRTLQKRKQGSSQKVAASAPKKNTNSNNSILKIYSDEATGLRVDPLVVLFLAVGFIFSVVALHVISKVAGKLF',
      trunc512 => '3ee63c430df30d169a3c79f81158abcf6629599c655dc6d8',
      found => 1,
    },
    {
      id => 'bogus',
      found => 0
    },
  ])
  ->content_type_is('application/vnd.ga4gh.seq.v1.0.0+json');

my $metadata_sub = sub {
  my ($stable_id, $synonyms) = @_;
  $synonyms //= [];
  my $mol = Molecule->find({ id => $stable_id });
  my $aliases = [
      { alias => $mol->seq->vmcdigest, naming_authority => 'vmc' },
      { alias => $stable_id, naming_authority => 'unknown' },
    @{$synonyms}
  ];

  my $expected = {
    metadata => {
      id => $mol->seq->trunc512,
      md5 => $mol->seq->md5,
      trunc512 => $mol->seq->trunc512,
      length => $mol->seq->size,
      aliases => $aliases
    }
  };

  $t->get_ok('/sequence/'.$mol->seq->trunc512.'/metadata' => { Accept => 'application/json'})
    ->status_is(200, 'Checking metadata status for '.$stable_id)
    ->or(sub { diag explain $t->tx->res })
    ->json_is($expected)
    ->or(sub { diag explain $t->tx->res->json; diag explain $expected});
  return;
};

$metadata_sub->('YER087C-B', [{ alias => 'synonym', naming_authority => 'unknown' }]);
$metadata_sub->('YHR055C');

done_testing();
