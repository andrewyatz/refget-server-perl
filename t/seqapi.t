use Test::More;

use strict;
use warnings;
use IO::Uncompress::Gunzip 'gunzip';
use IO::Compress::Gzip 'gzip';

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
    sha1 => '2db01e3048c926193f525e295662a901b274a461',
    sha256 => '118fc0d17e5eee7e0b98f770844fade5a717e8a78d86cf8b1f81a13ffdbd269b',
    size => 61,
  });
  my $seq2 = Seq->create({
    seq => 'MSSPTPPGGQRTLQKRKQGSSQKVAASAPKKNTNSNNSILKIYSDEATGLRVDPLVVLFLAVGFIFSVVALHVISKVAGKLF',
    md5 => 'c8e76de5f86131da26e8dd163658290d',
    sha1 => 'f5c6270cf86632900e741d865794f18a4ce98c8d',
    sha256 => '22e3e2203700e0b0879ed8b350febc086de4420b6e843d17e8d5e3a11461ae0f',
    size => 82,
  });
  my $seq3 = Seq->create({
    seq => 'ABCDEFGH',
    sha256 => 'e9a92a2ed0d53732ac13b031a27b071814231c8633c9f41844ccba884d482b16',
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

my $md5 = 'b6517aa110cc10776af5c368c5342f95';
my $seq_obj = Seq->get_seq($md5, 'md5');
my $raw_seq = $seq_obj->get_seq(SubSeq);
is($raw_seq, $raw_seq_one, 'Making sure sequence from API matches expected');

# Being used for the next 5 or so tests
my $basic_check_sub = sub {
  my ($checksum) = @_;
  $t->get_ok('/sequence/'.$checksum => { Accept => 'text/plain'})
    ->status_is(200)
    ->content_is($raw_seq);
};

foreach my $m (qw/md5 sha1 sha256/) {
  $basic_check_sub->($seq_obj->$m());
}

# Upper case vs lower case
$basic_check_sub->(lc($md5));
$basic_check_sub->(uc($md5));

# Basic URL
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
my $circ_sha = 'e9a92a2ed0d53732ac13b031a27b071814231c8633c9f41844ccba884d482b16';
$t->get_ok("/sequence/${circ_sha}?start=6&end=3", => {Accept => 'text/plain' })
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
  ->content_is(">118fc0d17e5eee7e0b98f770844fade5a717e8a78d86cf8b1f81a13ffdbd269b
MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSG
K");

# Trying head requests now
$t->head_ok($basic_url => { Accept => 'text/plain'})
  ->status_is(200)
  ->content_type_is($text_content_type)
  ->header_is('Content-Length', '61', 'Content-Length is the same as sequence length');

# Turn on Gzip and ensure we get content-length of the compressed content
$disable_gzip_accept_encoding = 0;
$t->head_ok($basic_url => { Accept => 'text/plain'})
  ->status_is(200, 'Accept-Encoding does not affect URL success')
  ->content_type_is($text_content_type, 'Content-Type remains text/plain with Accept-Encoding')
  ->header_is('Content-Length', '69', 'Content-Length of Accept-Encoding is set to 69');
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
gzip $raw_seq, \my $compressed_seq;
$disable_gzip_accept_encoding = 0;
$t->get_ok($basic_url => { Accept => 'text/plain' })
  ->status_is(200)
  ->content_is($raw_seq);
$disable_gzip_accept_encoding = 1;

# Batch retrieval
$t->post_ok('/batch/sequence'
  => { Accept => 'application/json' }
  => form => {
    id => ['2db01e3048c926193f525e295662a901b274a461', 'c8e76de5f86131da26e8dd163658290d', 'bogus']
  })
  ->status_is(200)
  ->json_is([
    {
      id => '2db01e3048c926193f525e295662a901b274a461',
      seq => 'MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSGK',
      sha1 => '2db01e3048c926193f525e295662a901b274a461',
      found => 1,
    },
    {
      id => 'c8e76de5f86131da26e8dd163658290d',
      seq => 'MSSPTPPGGQRTLQKRKQGSSQKVAASAPKKNTNSNNSILKIYSDEATGLRVDPLVVLFLAVGFIFSVVALHVISKVAGKLF',
      sha1 => 'f5c6270cf86632900e741d865794f18a4ce98c8d',
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
    { alias => $mol->seq->md5},
    { alias => $mol->seq->sha1 },
    { alias => $mol->seq->sha256 },
    { alias => $stable_id },
    @{$synonyms}
  ];

  $t->get_ok('/sequence/'.$mol->seq->sha1.'/metadata' => { Accept => 'application/json'})
    ->status_is(200, 'Checking metadata status for '.$stable_id)
    ->or(sub { diag explain $t->tx->res })
    ->json_is({
      metadata => {
        id => $mol->seq->sha1,
        length => $mol->seq->size,
        aliases => $aliases
      }
    })->or(sub { diag explain $t->tx->res->json });
  return;
};

$metadata_sub->('YER087C-B', [{alias => 'synonym'}]);
$metadata_sub->('YHR055C');

done_testing();
