#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
LDFLAGS='-L$PREFIX/lib'
CPPFLAGS='-I$PREFIX/include'
PREFIX=$PREFIX" > ~/.R/Makevars
$R CMD INSTALL --build .
