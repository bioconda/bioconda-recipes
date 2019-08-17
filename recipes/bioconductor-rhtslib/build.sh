#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
pushd src/htslib-1.7
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="-L${PREFIX}/lib"
popd
$R CMD INSTALL --build .
