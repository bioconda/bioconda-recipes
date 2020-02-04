#!/bin/sh
set -x -e

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include -lrt -std=gnu++11 -Wall -mssse3 -fopenmp"
export LDFLAGS="-L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="$CXX" CXXFLAGS="$CXXFLAGS"
cp Ninja ${PREFIX}/bin
