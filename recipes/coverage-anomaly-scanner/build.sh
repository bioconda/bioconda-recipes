#!/bin/bash

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LDLIBS="$LDLIBS -L$PREFIX/lib"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

git submodule init
git submodule update

make -C htslib

mkdir build

make print

cp cas $PREFIX/bin/
