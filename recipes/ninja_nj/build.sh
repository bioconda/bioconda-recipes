#!/bin/sh
set -x -e

export CXXFLAGS="-I$PREFIX/include -lrt -std=gnu++11 -Wall -mssse3 -fopenmp"

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="$CXX" CXXFLAGS="$CXXFLAGS"
cp Ninja ${PREFIX}/bin
