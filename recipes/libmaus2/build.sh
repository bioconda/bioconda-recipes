#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-lstdc++fs"

mkdir -p $PREFIX/lib
./configure
make
mv libmaus2.so $PREFIX/lib
