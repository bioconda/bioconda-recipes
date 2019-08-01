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
export LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64
ls -l $PREFIX/lib/R/library/rgl/libs
ldd -r $PREFIX/lib/R/library/rgl/libs/rgl.so
$R CMD INSTALL --build .
