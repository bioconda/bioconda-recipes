#!/bin/bash
set -ex
if [ "$(uname)" == Darwin ] ; then
        CXXFLAGS="$CXXFLAGS -fopenmp"
fi

make  

mkdir -p $PREFIX/bin

cp bin/gappa $PREFIX/bin

