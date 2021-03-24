#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}
make install
