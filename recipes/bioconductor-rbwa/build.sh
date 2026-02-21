#!/bin/bash

set -ex

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

# Ensure conda paths are visible to nested builds (e.g. bwa)
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export DFLAGS="${LDFLAGS} -L${PREFIX}/lib"

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
CPPFLAGS=${CPPFLAGS}
LDFLAGS=${LDFLAGS}
DFLAGS=${LDFLAGS}
" > ~/.R/Makevars

cat src/Makefile

$R CMD INSTALL --build .
