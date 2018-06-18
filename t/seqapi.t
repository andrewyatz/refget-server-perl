use Test::More;

use strict;
use warnings;

use Test::DBIx::Class {
  schema_class => 'Fastadb::Schema',
  resultsets => [ qw/Seq MolType Release Molecule Division Species/ ],
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

fixtures_ok sub {
  my $seq = Seq->create({
    seq => 'MFSELINFQNEGHECQCQCGSCKNNEQCQKSCSCPTGCNSDDKCPCGNKSEETKKSCCSGK',
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
  });
},'Installed fixtures';

# Set the application with the right schema. SQLite memory databases are a per driver thing
my $t = Test::Mojo->new('Fastadb::App');
$t->app->schema(Schema);

my $md5 = 'b6517aa110cc10776af5c368c5342f95';
my $seq_obj = Seq->get_seq($md5, 'md5');
my $raw_seq = $seq_obj->seq();
foreach my $m (qw/md5 trunc512 vmcdigest/) {
  $t->get_ok('/sequence/'.$seq_obj->$m() => { Accept => 'text/plain'})
    ->status_is(200)
    ->content_is($raw_seq);
}

# Uppercase checks
foreach my $m (qw/md5 trunc512/) {
  $t->get_ok('/sequence/'.uc($seq_obj->$m()) => { Accept => 'text/plain'})
    ->status_is(200)
    ->content_is($raw_seq);
}

# Just force vmcdigest checks
my $vmc_digest = 'VMC:GS_DxwXEkpq24VDow6GvCGRyxoWvCkxpWuo';
$t->get_ok('/sequence/'.$vmc_digest => { Accept => 'text/plain'})
    ->status_is(200)
    ->content_is($raw_seq);

# Trying Range requests
my $basic_url = '/sequence/'.$md5;
$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=59-61'})
  ->status_is(200)
  ->content_is('SGK');
$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=59'})
  ->status_is(400);
$t->get_ok($basic_url => { Accept => 'text/plain', Range => 'bytes=1-bogus'})
  ->status_is(400);
$t->get_ok($basic_url.'?start=0&end=1' => { Accept => 'text/plain', Range => 'bytes=1-2'})
  ->status_is(400)
  ->content_is('Invalid Input');

# Good substring request
$t->get_ok("/sequence/${md5}?start=0&end=1" => { Accept => 'text/plain' })
  ->status_is(200)
  ->content_is('M');

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

# Bad formats
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
  ->content_type_is('text/plain;charset=UTF-8')
  ->header_is('Content-Length', '61');

# Bogus sequence
$t->get_ok('/sequence/bogus' => { Accept => 'text/plain' })
  ->status_is(404)
  ->content_is('Not Found');

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
  ]);

my $stable_id = 'YER087C-B';
my $mol = Molecule->find({ id => $stable_id});
$t->get_ok('/metadata/'.$mol->seq->trunc512 => { Accept => 'application/json'})
	->status_is(200)
  ->or(sub { diag explain $t->tx->res })
  ->json_is({
    metadata => {
      id => $mol->seq->trunc512,
      length => 82,
      aliases => [
        { alias => $mol->seq->md5 },
        { alias => $mol->seq->trunc512 },
        { alias => $mol->seq->vmcdigest },
        { alias => $stable_id },
      ]
    }
  })->or(sub { diag explain $t->tx->res->json });

done_testing();
