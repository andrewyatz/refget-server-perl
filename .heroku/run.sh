#!/bin/bash

# Execute in $BUILD_DIR (which should be here)
tar zxf compliance-data.tar.gz

# Substiute the path of the build dir into the heroku config
perl -pi -e 's/%([^%]+)%/$ENV{$1}/g' $BUILD_DIR/.heroku/refget-app.heroku.json
