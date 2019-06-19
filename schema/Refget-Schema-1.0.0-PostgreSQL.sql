-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jun 19 20:03:38 2019
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
-- Table: raw_seq
--
DROP TABLE raw_seq CASCADE;
CREATE TABLE raw_seq (
  checksum character(48) NOT NULL,
  seq text NOT NULL,
  PRIMARY KEY (checksum)
);

--
-- Table: seq
--
DROP TABLE seq CASCADE;
CREATE TABLE seq (
  seq_id bigserial NOT NULL,
  md5 character(32) NOT NULL,
  trunc512 character(48) NOT NULL,
  size bigint NOT NULL,
  circular integer DEFAULT 0 NOT NULL,
  PRIMARY KEY (seq_id),
  CONSTRAINT seq_trunc512_uniq UNIQUE (trunc512)
);
CREATE INDEX md5_idx on seq (md5);
CREATE INDEX trunc512_idx on seq (trunc512);

--
-- Table: source
--
DROP TABLE source CASCADE;
CREATE TABLE source (
  source_id bigserial NOT NULL,
  source character varying(256) NOT NULL,
  PRIMARY KEY (source_id),
  CONSTRAINT source_uniq UNIQUE (source)
);

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
  seq_id bigint,
  release_id bigint NOT NULL,
  id character varying(128) NOT NULL,
  first_seen integer NOT NULL,
  mol_type_id bigint NOT NULL,
  version smallint,
  source_id bigint NOT NULL,
  PRIMARY KEY (molecule_id),
  CONSTRAINT molecule_uniq UNIQUE (id, mol_type_id)
);
CREATE INDEX molecule_idx_mol_type_id on molecule (mol_type_id);
CREATE INDEX molecule_idx_release_id on molecule (release_id);
CREATE INDEX molecule_idx_seq_id on molecule (seq_id);
CREATE INDEX molecule_idx_source_id on molecule (source_id);

--
-- Table: synonym
--
DROP TABLE synonym CASCADE;
CREATE TABLE synonym (
  synonym_id bigserial NOT NULL,
  molecule_id bigint NOT NULL,
  source_id bigint NOT NULL,
  synonym character varying(256) NOT NULL,
  PRIMARY KEY (synonym_id),
  CONSTRAINT synonym_uniq UNIQUE (molecule_id, synonym)
);
CREATE INDEX synonym_idx_molecule_id on synonym (molecule_id);
CREATE INDEX synonym_idx_source_id on synonym (source_id);

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

ALTER TABLE molecule ADD CONSTRAINT molecule_fk_source_id FOREIGN KEY (source_id)
  REFERENCES source (source_id) DEFERRABLE;

ALTER TABLE synonym ADD CONSTRAINT synonym_fk_molecule_id FOREIGN KEY (molecule_id)
  REFERENCES molecule (molecule_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE synonym ADD CONSTRAINT synonym_fk_source_id FOREIGN KEY (source_id)
  REFERENCES source (source_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

