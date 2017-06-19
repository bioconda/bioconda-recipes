#!/bin/bash

export R_LIBS_USER=':'
export LDFLAGS=-L${PREFIX}/lib
export BOOST_ROOT=${PREFIX}
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .
