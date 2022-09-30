#!/bin/bash

if [ `uname -s` == "Darwin" ];
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p build
cd build
cmake -DBOOST_INCLUDEDIR=${PREFIX}/include/ -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
cp ../bin/* $PREFIX/bin

if [ `uname -s` == "Linux" ];
then
    ln -s $PREFIX/lib/bamtools/libbamtools.so.2.3.0 $PREFIX/lib/libbamtools.so.2.3.0
fi
