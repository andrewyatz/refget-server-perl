#!/bin/bash

# Execute in $BUILD_DIR (which should be here)
tar zxf compliance-data.tar.gz

# Substiute the path of the build dir into the heroku config
cp .heroku/refget-app.heroku.json.template .heroku/refget-app.heroku.json

