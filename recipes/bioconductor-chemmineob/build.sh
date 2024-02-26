#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX -I$PREFIX/include/openbabel3 -I$PREFIX/include/eigen3 -L$PREFIX/lib
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX -I$PREFIX/include/openbabel3 -I$PREFIX/include/eigen3 -L$PREFIX/lib" > ~/.R/Makevars
$R CMD INSTALL --build .