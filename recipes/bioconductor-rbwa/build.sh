#!/bin/bash

set -ex

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

# upstream Makefile contains typo DFLAGS https://github.com/crisprVerse/Rbwa/issues/3
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
CPPFLAGS=${CPPFLAGS}
DFLAGS=${LDFLAGS}
" > ~/.R/Makevars

cd src
make
cd -

$R CMD INSTALL --build .
