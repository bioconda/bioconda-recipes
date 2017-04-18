#!/bin/bash

mkdir build
cd build

if [ `uname -s` == "Darwin" ];
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

cmake \
    -DBOOST_INCLUDEDIR=$PREFIX/include/ \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    ..

make
make install
cp ../bin/* $PREFIX/bin