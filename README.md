# Refget Reference Implementation Server

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

## Creating a Schema

The server can run off a variety of database types as it uses DBIx::Class. However we have tested the server with SQLite and Postgres. The latest database schemas are located in the `schema` directory. Pipe the SQL into your target database type and then give the server the database location.

# Running

The following will start an instance of [Mojo::Server::Daemon](https://metacpan.org/pod/Mojo::Server::Daemon) in production mode listening on port 8080 with the database location specified as a URL.

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
./bin/app.pl daemon -m production -l http://*:8080
```

Since this is a Mojolicous application you can use any of the supported servers such as [hypnotoad](https://metacpan.org/pod/Mojo::Server::Hypnotoad), [morbo](https://metacpan.org/pod/Mojo::Server::Morbo) or any PSGI compatible server. See [mojolicous's deployment guide](https://metacpan.org/pod/distribution/Mojolicious/lib/Mojolicious/Guides/Cookbook.pod#DEPLOYMENT) for more information on options.

# Populating the database

## Populating the dicts

Run the following command.

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
perl -I lib ./bin/populate-db-dicts.pl
```

This will populate all enumerated dictionaries of values with the default values.

## Populating it with with sequences

To load sequences into a database you can use the `bin/run.pl` script. The arguments are positional and are

1. FASTA input file
2. Release number to link to
3. Molecule type. Must be one of the supported types of `protein, cds, cdna, ncrna, dna`
4. Species. Give a species name
5. A division name. If unsure set to `none`
6. Assembly name. Normally set to the default name for an assembly. If one does not exist set it to none

```bash
export DATABASE_URL=postgres://username:password@server:port/databasename
perl -I lib ./bin/run.pl fasta.file 96 dna homo_sapiens none grch37
```

The script will iterate through the file, loads sequences if it were not already in the database and links additional metadata to the record. Please note this script was originally envisaged to load data from Ensembl resources hence a number of Ensembl conventions are present. These should not affect your usage of the loader code.

# Future Developments

- Support filesystem based sequence storage rather than using a database to hold sequences
- Better loading code
- More scripts for loading sequence aliases
