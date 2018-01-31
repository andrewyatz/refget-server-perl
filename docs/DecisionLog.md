# Decision Log

## 2018-01-31 - type as an attribute of molecule

Sequence is technically the entity that has a type e.g. dna, protein. However if type is added to sequence then there is a many to many relationship between sequences and molecules (shared IDs between sequences). We now allow multiple entries of the same ID so long as they were of a different molecule type.
