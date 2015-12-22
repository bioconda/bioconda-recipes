#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

# Add more build steps here, if they are necessary.
BIN=$PREFIX/bin
$R -e "flowr::setup(bin='$BIN')"

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
