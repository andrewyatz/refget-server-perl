-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Jan 26 16:13:19 2018
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
-- Table: seq_type
--
DROP TABLE seq_type;

CREATE TABLE seq_type (
  seq_type_id INTEGER PRIMARY KEY NOT NULL,
  seq_type varchar(256) NOT NULL
);

CREATE UNIQUE INDEX seq_type_uniq ON seq_type (seq_type);

--
-- Table: species
--
DROP TABLE species;

CREATE TABLE species (
  species_id INTEGER PRIMARY KEY NOT NULL,
  species varchar(256) NOT NULL
);

CREATE UNIQUE INDEX species_uniq ON species (species);

--
-- Table: seq
--
DROP TABLE seq;

CREATE TABLE seq (
  seq_id INTEGER PRIMARY KEY NOT NULL,
  seq text NOT NULL,
  seq_type_id integer(16) NOT NULL,
  md5 char(32) NOT NULL,
  sha1 char(40) NOT NULL,
  sha256 char(64) NOT NULL,
  size integer(11) NOT NULL,
  FOREIGN KEY (seq_type_id) REFERENCES seq_type(seq_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX seq_idx_seq_type_id ON seq (seq_type_id);

CREATE INDEX md5_idx ON seq (md5);

CREATE INDEX sha256_idx ON seq (sha256);

CREATE UNIQUE INDEX seq_sha1_uniq ON seq (sha1);

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
  stable_id varchar(128) NOT NULL,
  first_seen integer NOT NULL,
  version integer(4),
  FOREIGN KEY (release_id) REFERENCES release(release_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (seq_id) REFERENCES seq(seq_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX molecule_idx_release_id ON molecule (release_id);

CREATE INDEX molecule_idx_seq_id ON molecule (seq_id);

CREATE UNIQUE INDEX molecule_uniq ON molecule (stable_id);

COMMIT;