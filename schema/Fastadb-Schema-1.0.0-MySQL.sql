-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Fri Jan 26 16:13:19 2018
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS division;

--
-- Table: division
--
CREATE TABLE division (
  division_id integer(16) NOT NULL auto_increment,
  division text NOT NULL,
  PRIMARY KEY (division_id),
  UNIQUE division_uniq (division)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS seq_type;

--
-- Table: seq_type
--
CREATE TABLE seq_type (
  seq_type_id integer(16) NOT NULL auto_increment,
  seq_type text NOT NULL,
  PRIMARY KEY (seq_type_id),
  UNIQUE seq_type_uniq (seq_type)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS species;

--
-- Table: species
--
CREATE TABLE species (
  species_id integer(16) NOT NULL auto_increment,
  species text NOT NULL,
  PRIMARY KEY (species_id),
  UNIQUE species_uniq (species)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS seq;

--
-- Table: seq
--
CREATE TABLE seq (
  seq_id integer(16) NOT NULL auto_increment,
  seq text NOT NULL,
  seq_type_id integer(16) NOT NULL,
  md5 char(32) NOT NULL,
  sha1 char(40) NOT NULL,
  sha256 char(64) NOT NULL,
  size integer(11) NOT NULL,
  INDEX seq_idx_seq_type_id (seq_type_id),
  INDEX md5_idx (md5),
  INDEX sha256_idx (sha256),
  PRIMARY KEY (seq_id),
  UNIQUE seq_sha1_uniq (sha1),
  CONSTRAINT seq_fk_seq_type_id FOREIGN KEY (seq_type_id) REFERENCES seq_type (seq_type_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS release;

--
-- Table: release
--
CREATE TABLE release (
  release_id integer(16) NOT NULL auto_increment,
  release integer(16) NOT NULL,
  division_id integer(16) NOT NULL,
  species_id integer(16) NOT NULL,
  INDEX release_idx_division_id (division_id),
  INDEX release_idx_species_id (species_id),
  PRIMARY KEY (release_id),
  UNIQUE release_uniq (release, division_id, species_id),
  CONSTRAINT release_fk_division_id FOREIGN KEY (division_id) REFERENCES division (division_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT release_fk_species_id FOREIGN KEY (species_id) REFERENCES species (species_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS molecule;

--
-- Table: molecule
--
CREATE TABLE molecule (
  molecule_id integer(16) NOT NULL auto_increment,
  seq_id integer(16) NOT NULL,
  release_id integer(16) NOT NULL,
  stable_id varchar(128) NOT NULL,
  first_seen integer NOT NULL,
  version integer(4) NULL,
  INDEX molecule_idx_release_id (release_id),
  INDEX molecule_idx_seq_id (seq_id),
  PRIMARY KEY (molecule_id),
  UNIQUE molecule_uniq (stable_id),
  CONSTRAINT molecule_fk_release_id FOREIGN KEY (release_id) REFERENCES release (release_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT molecule_fk_seq_id FOREIGN KEY (seq_id) REFERENCES seq (seq_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

