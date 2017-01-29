#!/bin/bash
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin

./configure --prefix=${PREFIX}
make 
make install
