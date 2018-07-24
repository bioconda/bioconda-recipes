#!/bin/bash
cd HMMcopy
cmake .
export C_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
