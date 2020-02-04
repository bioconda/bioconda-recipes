#!/bin/sh
set -x -e

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include -lrt"
export LDFLAGS="-L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="$CXX" CC="$CC" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
cp Ninja ${PREFIX}/bin
