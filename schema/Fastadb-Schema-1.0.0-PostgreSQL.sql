-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Feb 14 10:38:50 2018
-- 
--
-- Table: division
--
DROP TABLE division CASCADE;
CREATE TABLE division (
  division_id bigserial NOT NULL,
  division character varying(256) NOT NULL,
  PRIMARY KEY (division_id),
  CONSTRAINT division_uniq UNIQUE (division)
);

--
-- Table: mol_type
--
DROP TABLE mol_type CASCADE;
CREATE TABLE mol_type (
  mol_type_id bigserial NOT NULL,
  type character varying(256) NOT NULL,
  PRIMARY KEY (mol_type_id),
  CONSTRAINT mol_type_uniq UNIQUE (type)
);

--
-- Table: seq
--
DROP TABLE seq CASCADE;
CREATE TABLE seq (
  seq_id bigserial NOT NULL,
  seq text NOT NULL,
  md5 character(32) NOT NULL,
  sha1 character(40) NOT NULL,
  sha256 character(64) NOT NULL,
  sha512 character(128) NOT NULL,
  size bigint NOT NULL,
  PRIMARY KEY (seq_id),
  CONSTRAINT seq_sha256_uniq UNIQUE (sha256)
);
CREATE INDEX md5_idx on seq (md5);
CREATE INDEX sha1_idx on seq (sha1);
CREATE INDEX sha512_idx on seq (sha512);

--
-- Table: species
--
DROP TABLE species CASCADE;
CREATE TABLE species (
  species_id bigserial NOT NULL,
  species character varying(256) NOT NULL,
  assembly character varying(256) NOT NULL,
  PRIMARY KEY (species_id),
  CONSTRAINT species_uniq UNIQUE (species, assembly)
);

--
-- Table: release
--
DROP TABLE release CASCADE;
CREATE TABLE release (
  release_id bigserial NOT NULL,
  release bigint NOT NULL,
  division_id bigint NOT NULL,
  species_id bigint NOT NULL,
  PRIMARY KEY (release_id),
  CONSTRAINT release_uniq UNIQUE (release, division_id, species_id)
);
CREATE INDEX release_idx_division_id on release (division_id);
CREATE INDEX release_idx_species_id on release (species_id);

--
-- Table: molecule
--
DROP TABLE molecule CASCADE;
CREATE TABLE molecule (
  molecule_id bigserial NOT NULL,
  seq_id bigint NOT NULL,
  release_id bigint NOT NULL,
  id character varying(128) NOT NULL,
  first_seen integer NOT NULL,
  mol_type_id bigint NOT NULL,
  version smallint,
  PRIMARY KEY (molecule_id),
  CONSTRAINT molecule_uniq UNIQUE (id, mol_type_id)
);
CREATE INDEX molecule_idx_mol_type_id on molecule (mol_type_id);
CREATE INDEX molecule_idx_release_id on molecule (release_id);
CREATE INDEX molecule_idx_seq_id on molecule (seq_id);

--
-- Foreign Key Definitions
--

ALTER TABLE release ADD CONSTRAINT release_fk_division_id FOREIGN KEY (division_id)
  REFERENCES division (division_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE release ADD CONSTRAINT release_fk_species_id FOREIGN KEY (species_id)
  REFERENCES species (species_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE molecule ADD CONSTRAINT molecule_fk_mol_type_id FOREIGN KEY (mol_type_id)
  REFERENCES mol_type (mol_type_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE molecule ADD CONSTRAINT molecule_fk_release_id FOREIGN KEY (release_id)
  REFERENCES release (release_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE molecule ADD CONSTRAINT molecule_fk_seq_id FOREIGN KEY (seq_id)
  REFERENCES seq (seq_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

