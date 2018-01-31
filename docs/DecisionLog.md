# Decision Log

## 2018-01-31 - type as an attribute of molecule

Sequence is technically the entity that has a type e.g. dna, protein. However if type is added to sequence then there is a many to many relationship between sequences and molecules (shared IDs between sequences). We now allow multiple entries of the same ID so long as they were of a different molecule type.

## 2018-01-31 - batch retrieval

Batch retrieval is supported via `/batch/sequence` using POST. We respond to the parameter id, loop through and return a JSON hash for each with the structure `id` (the submitted id), `seq`, `sha1` and `found` (indicating if we found the sequence or not). `id` follows the same semantics as `/sequence/:id`. We do not support multiple subseq requests. We also create a fresh base root `/batch` to avoid confusion with `/sequence/XXXXXX` extensions that might appear in the future. This is not part of the GA4GH API.
