# Refget Reference Implementation Server

The refget reference implementation server is a Perl version of the refget protocol. The server uses a database to store metadata about a set of sequences and uses a local filesystem to store sequences in. The sequences are stored on disk as single line sequences with no whitespace and indexed under their checksum using the first 4 characters of the checksum to generate a directory hierarchy. This is the same mechanism used by htslib to create local sequence caches for CRAM files.

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

By default the application expects to find a file called `refget-app.json` in the root directory. You can alter this by specifying `MOJO_CONFIG=path/to/json`. Consult the file `refget-app.json.example` for available configuration variables.

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
7. A root directory to store sequences in. Must be set
8. A commit rate (how many times we should commit on our inserts)

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
perl -I lib ./bin/run.pl fasta.file 96 dna homo_sapiens none grch37 ./hts-ref 1000
```

The script will iterate through the file, loads sequences if it were not already in the database and links additional metadata to the record. Please note this script was originally envisaged to load data from Ensembl resources hence a number of Ensembl conventions are present. These should not affect your usage of the loader code.

# Generating Schemas

```bash
perl -I lib ./bin/schema.pl
```

When executed from the root directory, this will create a set of schemas located in the `schema` directory. Version of schemas are controlled by the `$Refget::Schema::VERSION` variable located in `lib/Refget/Schema.pm`.

# Future Developments

- Better loading code
- More scripts for loading sequence aliases
