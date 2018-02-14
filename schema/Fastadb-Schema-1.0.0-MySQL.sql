-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Feb 14 13:06:25 2018
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

DROP TABLE IF EXISTS mol_type;

--
-- Table: mol_type
--
CREATE TABLE mol_type (
  mol_type_id integer(16) NOT NULL auto_increment,
  type text NOT NULL,
  PRIMARY KEY (mol_type_id),
  UNIQUE mol_type_uniq (type)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS seq;

--
-- Table: seq
--
CREATE TABLE seq (
  seq_id integer(16) NOT NULL auto_increment,
  seq text NOT NULL,
  md5 char(32) NOT NULL,
  sha1 char(40) NOT NULL,
  sha256 char(64) NOT NULL,
  sha512 char(128) NOT NULL,
  size integer(11) NOT NULL,
  circular integer NOT NULL DEFAULT 0,
  INDEX md5_idx (md5),
  INDEX sha1_idx (sha1),
  INDEX sha512_idx (sha512),
  PRIMARY KEY (seq_id),
  UNIQUE seq_sha256_uniq (sha256)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS species;

--
-- Table: species
--
CREATE TABLE species (
  species_id integer(16) NOT NULL auto_increment,
  species text NOT NULL,
  assembly text NOT NULL,
  PRIMARY KEY (species_id),
  UNIQUE species_uniq (species, assembly)
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
  id varchar(128) NOT NULL,
  first_seen integer NOT NULL,
  mol_type_id integer(16) NOT NULL,
  version integer(4) NULL,
  INDEX molecule_idx_mol_type_id (mol_type_id),
  INDEX molecule_idx_release_id (release_id),
  INDEX molecule_idx_seq_id (seq_id),
  PRIMARY KEY (molecule_id),
  UNIQUE molecule_uniq (id, mol_type_id),
  CONSTRAINT molecule_fk_mol_type_id FOREIGN KEY (mol_type_id) REFERENCES mol_type (mol_type_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT molecule_fk_release_id FOREIGN KEY (release_id) REFERENCES release (release_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT molecule_fk_seq_id FOREIGN KEY (seq_id) REFERENCES seq (seq_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

