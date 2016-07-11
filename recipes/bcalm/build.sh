#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH=${PREFIX} ..
make
cp bcalm $PREFIX/bin
