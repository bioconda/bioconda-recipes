#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
if [[ "$HOST" == *"linux-gnu" ]]; then
    ln -s $FC ${PREFIX}/bin/gfortran
fi
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
sed -i.bak "s#FC=`grep '^FC ' ${R_HOME}/etc${R_ARCH}/Makeconf|cut -c6-`#FC=\"gfortran\"#" configure
$R CMD INSTALL --build .
if [[ "$HOST" == *"linux-gnu" ]]; then
    rm ${PREFIX}/bin/gfortran
fi
