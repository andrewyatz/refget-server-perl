#!/bin/bash

mkdir -p compliance-data

# Setup the database
export COMPLIANCE=${PWD}/compliance-data
export DATABASE_LOC=${COMPLIANCE}/compliance.db
export DATABASE_URL=sqlite:///$DATABASE_LOC
export TARBALL=compliance-data.tar.gz
version=$(perl -I lib -MRefget::Schema -e 'print $Refget::Schema::VERSION')

echo '====> CLEANUP AND SETUP'
if [ -d ${COMPLIANCE} ]; then
  echo '      removing compliance directory'
  rm -rf ${COMPLIANCE}
fi
if [ -f $TARBALL ]; then
  echo '      removing compliance tarball'
  rm $TARBALL
fi
  echo '      make compliance directory'
mkdir $COMPLIANCE

echo '====> CREATE SCHEMA'
sqlite3 $DATABASE_LOC < schema/Refget-Schema-${version}-SQLite.sql 2>/dev/null

# Populate
echo '====> POPULATE DICTIONARIES'
perl -I lib ./bin/populate-db-dicts.pl

echo '====> LOAD COMPLIANCE DATA'
perl -I lib ./bin/run.pl compliance/refget-compliance.fa 1 dna none none none 1 $PWD/compliance/config.json

echo '====> PATCH COMPLIANCE DATA'
sqlite3 $DATABASE_LOC < $PWD/compliance/data.sqlite3.sql

# Tarball
echo '====> BUILD TARBALL COMPLIANCE'
tar zcf $TARBALL compliance-data

echo '====> DONE'
