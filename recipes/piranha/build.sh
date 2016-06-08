#!/bin/sh

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CXXFLAGS="-I${INCLUDE_PATH} -L${LIBRARY_PATH}"
export LDFLAGS="-L${LIBRARY_PATH}"

mkdir -p $PREFIX/bin

autoconf
./configure
make
# make test
make install
cp bin/* $PREFIX/bin
