#!/bin/bash

#strictly use anaconda build environment
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

# R refuses to build packages that mark themselves as
# "Priority: Recommended"

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .
