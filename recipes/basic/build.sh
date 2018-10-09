#!/bin/bash

mkdir -p $PREFIX/db/basic
mkdir -p $PREFIX/bin
cp -rf db/* $PREFIX/db/basic/

# replace /db/ path with /../db/basic/
sed "s;/db;/../db/basic/;g" BASIC.py > $PREFIX/bin/BASIC.py
chmod +x $PREFIX/bin/BASIC.py

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
