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
export C_INCLUDE_PATH=${PATH}/include
export LIBRARY_PATH=${PATH}/lib
cd src && make CC=$CC CFLAGS=$CFLAGS && cd ..
$R CMD INSTALL --build .
