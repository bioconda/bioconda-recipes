#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
touch GLAD
$R CMD INSTALL --build --configure-vars='GSL_LIBS="-L$PREFIX/lib -lgsl -lgslcblas -lm"' .
