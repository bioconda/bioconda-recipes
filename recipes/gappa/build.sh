#!/bin/bash

if [ "$(uname)" == Darwin ] ; then
        CXXFLAGS="$CXXFLAGS -fopenmp"
fi

make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin

chmod 0755 bin/gappa
cp bin/gappa $PREFIX/bin
