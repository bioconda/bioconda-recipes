#!/bin/sh
set -x -e

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -lrt"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${C_INCLUDE_PATH}:${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="$CXX" CC="$CC" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
cp Ninja ${PREFIX}/bin
