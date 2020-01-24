#!/bin/bash

export CXXFLAGS="-std=c++11"
export INCLUDE_PATH=${PREFIX}/include
export GSL_INCLUDE_DIRS=${PREFIX}/include
export GSL_LIBRARY_DIRS=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin
