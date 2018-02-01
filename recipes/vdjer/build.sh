#!/bin/bash

mkdir -p $PREFIX/bin
make
cp -f vdjer $PREFIX/bin/vdjer
chmod +x $PREFIX/bin/vdjer

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
