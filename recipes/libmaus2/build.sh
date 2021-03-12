#!/bin/bash
set -eu

mkdir -p $PREFIX/lib
export LDFLAGS="-lstdc++fs"
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

./configure --prefix $PREFIX
make
make install
