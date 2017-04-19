#!/bin/bash

mkdir build
cd build

if [ `uname -s` == "Darwin" ];
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake \
    -DBOOST_INCLUDEDIR=$PREFIX/include/ \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    ..

make
make install
cp ../bin/* $PREFIX/bin