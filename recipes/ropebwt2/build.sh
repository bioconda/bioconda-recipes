#!/bin/bash

#strictly use anaconda build environment
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin
make 
mv ropebwt2  $PREFIX/bin

