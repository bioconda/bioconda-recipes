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
export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64:${BUILD_PREFIX}/lib
$R CMD INSTALL --build .