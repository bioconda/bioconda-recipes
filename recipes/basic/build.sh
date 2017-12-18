#!/bin/bash

mkdir -p $PREFIX/db/basic
mkdir -p $PREFIX/bin
cp -rf db/* $PREFIX/db/basic/

# replace /db/ path with /../db/basic/
# add shebang to first line
sed "s;/db/;/../db/basic/;g" BASIC.py | sed "1s;^;#\!/usr/bin/env python\n;" > $PREFIX/bin/BASIC.py
chmod +x $PREFIX/bin/BASIC.py

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
