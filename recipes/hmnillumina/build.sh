#!/bin/bash
set -eu -o pipefail

# Compile
LIBS="-I include -l interop_lib -L $PREFIX/interop/lib64 -I $PREFIX/interop/include -I $PREFIX/include -I $PREFIX/include/rapidjson -L $PREFIX/lib"
CXXFLAGS="-std=c++11 -Wall -O3 -lz -fopenmp"

make CXX="$CXX" LIBS="$LIBS" CXXFLAGS="$CXXFLAGS"
mkdir -p $PREFIX/bin
mv HmnIllumina $PREFIX/bin
