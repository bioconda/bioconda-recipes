#!/bin/bash

unamestr=`uname`
export LD_LIBRARY_PATH=${PREFIX}/lib

if [ $unamestr == 'Darwin' ];
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
#    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
    CXX=clang++;
    CC=clang;
fi

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cat config.log
