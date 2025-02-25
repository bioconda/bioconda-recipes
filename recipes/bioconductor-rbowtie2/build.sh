#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX -I${PREFIX}/include -L${PREFIX}/lib
CXX98=$CXX -I${PREFIX}/include -L${PREFIX}/lib
CXX11=$CXX -I${PREFIX}/include -L${PREFIX}/lib
CXX14=$CXX -I${PREFIX}/include -L${PREFIX}/lib" > ~/.R/Makevars
export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64:${BUILD_PREFIX}/lib
$R CMD INSTALL --build .