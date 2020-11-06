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
sed -i.bak "s/-TP//" src/SYMPHONY/SYMPHONY/configure.ac
sed -i.bak "s/-TP//" src/SYMPHONY/SYMPHONY/configure
$R CMD INSTALL --build .
