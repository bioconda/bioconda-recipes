#!/bin/sh
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/bin

make

cp bin/* $PREFIX/bin
