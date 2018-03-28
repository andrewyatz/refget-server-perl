-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Mar 28 15:13:38 2018
-- 

BEGIN TRANSACTION;

--
-- Table: division
--
DROP TABLE division;

CREATE TABLE division (
  division_id INTEGER PRIMARY KEY NOT NULL,
  division varchar(256) NOT NULL
);

CREATE UNIQUE INDEX division_uniq ON division (division);

--
-- Table: mol_type
--
DROP TABLE mol_type;

CREATE TABLE mol_type (
  mol_type_id INTEGER PRIMARY KEY NOT NULL,
  type varchar(256) NOT NULL
);

CREATE UNIQUE INDEX mol_type_uniq ON mol_type (type);

--
-- Table: seq
--
DROP TABLE seq;

CREATE TABLE seq (
  seq_id INTEGER PRIMARY KEY NOT NULL,
  seq text NOT NULL,
  md5 char(32) NOT NULL,
  sha1 char(40) NOT NULL,
  sha256 char(64) NOT NULL,
  sha512 char(128) NOT NULL,
  size integer(11) NOT NULL,
  circular integer NOT NULL DEFAULT 0
);

CREATE INDEX md5_idx ON seq (md5);

CREATE INDEX sha1_idx ON seq (sha1);

CREATE INDEX sha512_idx ON seq (sha512);

CREATE UNIQUE INDEX seq_sha256_uniq ON seq (sha256);

--
-- Table: species
--
DROP TABLE species;

CREATE TABLE species (
  species_id INTEGER PRIMARY KEY NOT NULL,
  species varchar(256) NOT NULL,
  assembly varchar(256) NOT NULL
);

CREATE UNIQUE INDEX species_uniq ON species (species, assembly);

--
-- Table: release
--
DROP TABLE release;

CREATE TABLE release (
  release_id INTEGER PRIMARY KEY NOT NULL,
  release integer(16) NOT NULL,
  division_id integer(16) NOT NULL,
  species_id integer(16) NOT NULL,
  FOREIGN KEY (division_id) REFERENCES division(division_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (species_id) REFERENCES species(species_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX release_idx_division_id ON release (division_id);

CREATE INDEX release_idx_species_id ON release (species_id);

CREATE UNIQUE INDEX release_uniq ON release (release, division_id, species_id);

--
-- Table: molecule
--
DROP TABLE molecule;

CREATE TABLE molecule (
  molecule_id INTEGER PRIMARY KEY NOT NULL,
  seq_id integer(16) NOT NULL,
  release_id integer(16) NOT NULL,
  id varchar(128) NOT NULL,
  first_seen integer NOT NULL,
  mol_type_id integer(16) NOT NULL,
  version integer(4),
  FOREIGN KEY (mol_type_id) REFERENCES mol_type(mol_type_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (release_id) REFERENCES release(release_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (seq_id) REFERENCES seq(seq_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX molecule_idx_mol_type_id ON molecule (mol_type_id);

CREATE INDEX molecule_idx_release_id ON molecule (release_id);

CREATE INDEX molecule_idx_seq_id ON molecule (seq_id);

CREATE UNIQUE INDEX molecule_uniq ON molecule (id, mol_type_id);

--
-- Table: synonym
--
DROP TABLE synonym;

CREATE TABLE synonym (
  synonym_id INTEGER PRIMARY KEY NOT NULL,
  molecule_id integer(16) NOT NULL,
  synonym varchar(256) NOT NULL,
  FOREIGN KEY (molecule_id) REFERENCES molecule(molecule_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX synonym_idx_molecule_id ON synonym (molecule_id);

CREATE UNIQUE INDEX synonym_uniq ON synonym (molecule_id, synonym);

COMMIT;
