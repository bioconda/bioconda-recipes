#!/bin/sh
set -x -e

if [[ $(uname -s) == "Linux" ]]; then
  export CXXFLAGS="-I$PREFIX/include -lrt -std=gnu++11 -Wall -mssse3 -fopenmp"
else
  export CXXFLAGS="-I$PREFIX/include -std=gnu++11 -Wall -mssse3 -fopenmp"
fi

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="$CXX" CXXFLAGS="$CXXFLAGS"
cp Ninja ${PREFIX}/bin
