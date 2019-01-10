#!/bin/bash

CXXFLAGS="$CXXFLAGS"
LDFLAGS="$LDFLAGS"
if [ "$(uname)" == Darwin ] ; then
        CXXFLAGS="$CXXFLAGS -Wl,-rpath ${PREFIX}/lib -L${PREFIX}/lib -I${PREFIX}/include -fopenmp"
fi

make  

mkdir -p $PREFIX/bin

cp bin/gappa $PREFIX/bin

