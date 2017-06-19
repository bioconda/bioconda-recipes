#!/bin/bash

if [ `uname` == Darwin ]; then
        export LDFLAGS=-L${PREFIX}/lib
fi
export BOOST_ROOT=${PREFIX}
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .
