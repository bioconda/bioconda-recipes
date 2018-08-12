#!/bin/sh

export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
# build alfred
make all
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
