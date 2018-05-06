#!/bin/bash

unamestr=`uname`
export LD_LIBRARY_PATH=${PREFIX}/lib

if [ $unamestr == 'Darwin' ];
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    MACOSX_DEPLOYMENT_TARGET=10.9
    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
fi

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cat config.log
