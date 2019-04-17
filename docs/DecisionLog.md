# Decision Log

## 2019-04-17 - Fastadb is now Refget

Global package name change to be more inline with the way this is named.

## 2019-04-16 - New file and database based sequence storage

Switch to using a file based system for sequence. Means a refget server can be run off a htslib generated hts-ref directory (if the server uses md5 as the default checksum). System allows for the sequence storage to be changed to any other system so long as it can implemented a `_sub_seq` and a `store` method. Schema was also changed so that database storage of sequences is still supported but in the `raw_seq` table not the `seq` table.

## 2018-02-02 - Swagger Support

Write up the current proposed specification as a swagger API definition. Provides documentation for downstream users

## 2018-02-02 - Add assembly to a species

Add assembly to a species as the sequence arises from both species and assembly version not just the species

## 2018-02-01 - Support range

Simple range support brought in as per the specification

## 2018-02-01 - CORS. Remove credentials

We have no credentials so we have removed the header

## 2018-01-31 - type as an attribute of molecule

Sequence is technically the entity that has a type e.g. dna, protein. However if type is added to sequence then there is a many to many relationship between sequences and molecules (shared IDs between sequences). We now allow multiple entries of the same ID so long as they were of a different molecule type.

## 2018-01-31 - batch retrieval

Batch retrieval is supported via `/batch/sequence` using POST. We respond to the parameter id, loop through and return a JSON hash for each with the structure `id` (the submitted id), `seq`, `sha1` and `found` (indicating if we found the sequence or not). `id` follows the same semantics as `/sequence/:id`. We do not support multiple subseq requests. We also create a fresh base root `/batch` to avoid confusion with `/sequence/XXXXXX` extensions that might appear in the future. This is not part of the GA4GH API.

## 2018-01-31 - CORS

CORS is enabled at the root application layer and only when an `Origin` header is sent through. We send back `Access-Control-Allow-Origin`, `Access-Control-Allow-Headers`, `Access-Control-Allow-Methods`, `Access-Control-Max-Age` and `Access-Control-Allow-Credentials`. `OPTIONS` is supported on requests to the root url i.e. `/` only. `A-C-A-Credentials` defaults to true except for when an OPTION request comes in. This seems to be inline with the CORS specification and what has been defined by the GA4GH API spec.
