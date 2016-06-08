#!/bin/sh

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CXXFLAGS="-I${INCLUDE_PATH} -L${LIBRARY_PATH}"

autoconf
./configure
make
make test
make install

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/
