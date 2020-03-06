# Refget Reference Implementation Server

The refget reference implementation server is a Perl version of the refget protocol. The server uses a database to store metadata about a set of sequences and either a database, file system or redis store to hold sequences. See later for details on available sequence storage layers.

# Installing

## Pre-requisites

- GCC
- Perl 5.14+
- cpanminus
- Postgres development headers

## Installing Perl Dependencies

```bash
cpanm --installdeps .
```
# Database URLs

The system supports setting a database URL held in the variable `DATABASE_URL`. These are formatted as `database://username:password@server:port/database`. SQLite is supported by specifying just a database name e.g. `sqlite:///database_path.db`

## Creating a schema

The server can run off a variety of database types as it uses DBIx::Class. However we have tested the server with SQLite and Postgres. The latest database schemas are located in the `schema` directory. Pipe the SQL into your target database type and then give the server the database location.

# Running

## Configuration

### Config file

By default the application expects to find a file called `refget-app.json` in the root directory. You can alter this by specifying `MOJO_CONFIG=path/to/json`. Consult the file `refget-app.json.example` for available configuration variables. This file is used to configure the sequence storage layer.

### Environment variables

Note these config variables pre-date the use of a configuration file. In time many of these options will migrate into the config file.

- `MOJO_CONFIG`: Control the location of the configuration file
- `DATABASE_URL`: Location of the database (see earlier for a description)
- `APP_PID_FILE`: If executing using Hypnotoad, set the location of the PID file
- `APP_LOG_FILE`: Write logs to this file via `Mojo::Log`
- `APP_LOG_LEVEL`: The level of log to record. Options are `debug`, `info`, `warn`, `error`, `fatal`
- `APP_ACCESS_LOG_FILE`: Location of the access log file to write using `Mojolicous::Plugin::AccessLog`
- `APP_ACCESS_LOG_FORMAT`: Format of access log to write. Options are `common`, `combined`, `combinedio` or you can specify your own Apache LogFormat string
- `APP_ENABLE_COMPRESSION`: Enable on-the-wire gzip compression on responses

## Running the server

The following will start an instance of [Mojo::Server::Daemon](https://metacpan.org/pod/Mojo::Server::Daemon) in production mode listening on port 8080 with the database location specified as a URL.

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
export MOJO_CONFIG="refget-app.json"
./bin/app.pl daemon -m production -l http://*:8080
```

Since this is a Mojolicous application you can use any of the supported servers such as [hypnotoad](https://metacpan.org/pod/Mojo::Server::Hypnotoad), [morbo](https://metacpan.org/pod/Mojo::Server::Morbo) or any PSGI compatible server. See [mojolicous's deployment guide](https://metacpan.org/pod/distribution/Mojolicious/lib/Mojolicious/Guides/Cookbook.pod#DEPLOYMENT) for more information on options.

# Populating the database

## Populating the dictionaries

Run the following command.

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
perl -I lib ./bin/populate-db-dicts.pl
```

This will populate all enumerated dictionaries of values with the default values.

## Populating it with with sequence metadata and the filesystem with sequences

To load sequences into a database you can use the `bin/run.pl` script. The arguments are positional and are

1. FASTA input file
2. Release number to link to
3. Molecule type. Must be one of the supported types of `protein, cds, cdna, ncrna, dna`
4. Species. Give a species name
5. A division name. If unsure set to `none`
6. Assembly name. Normally set to the default name for an assembly. If one does not exist set it to `none`
7. Source. Set to the source input of your sequence (Ensembl, RefSeq, UCSC, INSDC, unknown)
8. A commit rate (how many times we should commit on our inserts)
9. A path to the config file. Used to create an appropriate sequence storage layer

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
perl -I lib ./bin/run.pl fasta.file 96 dna homo_sapiens none grch37 Ensembl 1000 path/to/config.json
```

The script will iterate through the file, loads sequences if it were not already in the database and links additional metadata to the record. Please note this script was originally envisaged to load data from Ensembl resources hence a number of Ensembl conventions are present. These should not affect your usage of the loader code.

# Generating Schemas

```bash
perl -I lib ./bin/schema.pl
```

When executed from the root directory, this will create a set of schemas located in the `schema` directory. Version of schemas are controlled by the `$Refget::Schema::VERSION` variable located in `lib/Refget/Schema.pm`.

# Sequence Storage Layers

Three types of sequences storage layers exist; File, DBIx and Redis. All storage layers require you to specify the checksum to use for indexing. A sequence storage layer can work with only one checksum and requires the metadata systems to normalise into this single key. Whilst DBIx is the simplest to configure both the file and Redis layers have some advantages such as scalability to numbers of sequences or speed of access. Ultimately it is up to the implementation to understand what is important and to use the appropriate storage layer.

## File Storage

File storage creates a htslib like `hts-ref` storage system, where a directory hierarchy is created. The first two levels are the first and second hex number from the generated HASH e.g. the sequence for `959cb1883fc1ca9ae1394ceb475a356ead1ecceff5824ae7` is held under `95/9c/959cb1883fc1ca9ae1394ceb475a356ead1ecceff5824ae7`.

### Configuration

```json
{
  "seq_store" : "File",
  "seq_store_args" : {
    "root_dir" : "/path/to/storage/area",
    "checksum" : "trunc512"
  }
}
```

## DBIx

DBIx storage uses the same database as where all loaded sequence metadata goes and pushes data into a table called `raw_seq`, which is indexed by the chosen checksum identifier. This is the simplest storage system to use as it keeps metadata and sequence together.

### Configuration

```json
{
  "seq_store" : "DBIx",
  "seq_store_args" : {
    "checksum" : "trunc512"
  }
}
```

## Redis

Redis storage uses the Redis database to store and access data. The code uses Redis' `GETRANGE` function to retrieve sub-sequences. You configure the instance by passing through parameters meant for the [Perl Redis module](https://metacpan.org/pod/Redis).

### Configuration

```json
{
  "seq_store" : "Redis",
  "seq_store_args" : {
    "server" : "127.0.0.1:6379"
  }
}
```
## Supporting additional layers

Additional layers can be supported. They require using the `Refget::SeqStore::Base` Moose role. This requires you to implement two methods `_store(self, checksum, sequence)` and `_sub_seq(self, checksum, start, length)`. Once created the new storage layer can be added to the list of allowed layers in `Refget::SeqStore::Builder`.

# Running tests

The following command will run all tests in the `t` directory. Tests can be individually run as a perl script. All tests are run against our CI server on each commit.

```bash
prove -I lib/ t/
```

# Future Developments

- Better loading code
- More scripts for loading sequence aliases
