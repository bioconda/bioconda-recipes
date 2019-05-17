#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
ln -s $FC ${PREFIX}/bin/gfortran
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
sed -i.bak "1652i\\
  FC=\"gfortran\"" configure
$R CMD INSTALL --build .
rm ${PREFIX}/bin/gfortran
