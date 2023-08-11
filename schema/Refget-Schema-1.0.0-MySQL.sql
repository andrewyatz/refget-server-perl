--
-- Created by SQL::Translator::Producer::MySQL
-- Created on Fri Aug 11 11:56:25 2023
--
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `division`;

--
-- Table: `division`
--
CREATE TABLE `division` (
  `division_id` integer(16) NOT NULL auto_increment,
  `division` varchar(256) NOT NULL,
  PRIMARY KEY (`division_id`),
  UNIQUE `division_uniq` (`division`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `mol_type`;

--
-- Table: `mol_type`
--
CREATE TABLE `mol_type` (
  `mol_type_id` integer(16) NOT NULL auto_increment,
  `type` varchar(256) NOT NULL,
  PRIMARY KEY (`mol_type_id`),
  UNIQUE `mol_type_uniq` (`type`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `raw_seq`;

--
-- Table: `raw_seq`
--
CREATE TABLE `raw_seq` (
  `checksum` char(48) NOT NULL,
  `seq` text NOT NULL,
  PRIMARY KEY (`checksum`)
);

DROP TABLE IF EXISTS `seq`;

--
-- Table: `seq`
--
CREATE TABLE `seq` (
  `seq_id` integer(16) NOT NULL auto_increment,
  `md5` char(32) NOT NULL,
  `trunc512` char(48) NOT NULL,
  `size` integer(11) NOT NULL,
  `circular` integer NOT NULL DEFAULT 0,
  INDEX `md5_idx` (`md5`),
  INDEX `trunc512_idx` (`trunc512`),
  PRIMARY KEY (`seq_id`),
  UNIQUE `seq_trunc512_uniq` (`trunc512`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `source`;

--
-- Table: `source`
--
CREATE TABLE `source` (
  `source_id` integer(16) NOT NULL auto_increment,
  `source` varchar(256) NOT NULL,
  PRIMARY KEY (`source_id`),
  UNIQUE `source_uniq` (`source`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `species`;

--
-- Table: `species`
--
CREATE TABLE `species` (
  `species_id` integer(16) NOT NULL auto_increment,
  `species` varchar(256) NOT NULL,
  `assembly` varchar(256) NOT NULL,
  PRIMARY KEY (`species_id`),
  UNIQUE `species_uniq` (`species`, `assembly`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `release`;

--
-- Table: `release`
--
CREATE TABLE `release` (
  `release_id` integer(16) NOT NULL auto_increment,
  `release` integer(16) NOT NULL,
  `division_id` integer(16) NOT NULL,
  `species_id` integer(16) NOT NULL,
  INDEX `release_idx_division_id` (`division_id`),
  INDEX `release_idx_species_id` (`species_id`),
  PRIMARY KEY (`release_id`),
  UNIQUE `release_uniq` (`release`, `division_id`, `species_id`),
  CONSTRAINT `release_fk_division_id` FOREIGN KEY (`division_id`) REFERENCES `division` (`division_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `release_fk_species_id` FOREIGN KEY (`species_id`) REFERENCES `species` (`species_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `molecule`;

--
-- Table: `molecule`
--
CREATE TABLE `molecule` (
  `molecule_id` integer(16) NOT NULL auto_increment,
  `seq_id` integer(16) NULL,
  `release_id` integer(16) NOT NULL,
  `id` varchar(128) NOT NULL,
  `first_seen` integer NOT NULL,
  `mol_type_id` integer(16) NOT NULL,
  `version` integer(4) NULL,
  `source_id` integer(16) NOT NULL,
  INDEX `molecule_idx_mol_type_id` (`mol_type_id`),
  INDEX `molecule_idx_release_id` (`release_id`),
  INDEX `molecule_idx_seq_id` (`seq_id`),
  INDEX `molecule_idx_source_id` (`source_id`),
  PRIMARY KEY (`molecule_id`),
  UNIQUE `molecule_uniq` (`id`, `mol_type_id`, `release_id`, `source_id`),
  CONSTRAINT `molecule_fk_mol_type_id` FOREIGN KEY (`mol_type_id`) REFERENCES `mol_type` (`mol_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `molecule_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release` (`release_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `molecule_fk_seq_id` FOREIGN KEY (`seq_id`) REFERENCES `seq` (`seq_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `molecule_fk_source_id` FOREIGN KEY (`source_id`) REFERENCES `source` (`source_id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `synonym`;

--
-- Table: `synonym`
--
CREATE TABLE `synonym` (
  `synonym_id` integer(16) NOT NULL auto_increment,
  `molecule_id` integer(16) NOT NULL,
  `source_id` integer(16) NOT NULL,
  `synonym` varchar(256) NOT NULL,
  INDEX `synonym_idx_molecule_id` (`molecule_id`),
  INDEX `synonym_idx_source_id` (`source_id`),
  PRIMARY KEY (`synonym_id`),
  UNIQUE `synonym_uniq` (`molecule_id`, `synonym`),
  CONSTRAINT `synonym_fk_molecule_id` FOREIGN KEY (`molecule_id`) REFERENCES `molecule` (`molecule_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `synonym_fk_source_id` FOREIGN KEY (`source_id`) REFERENCES `source` (`source_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

