#!/bin/bash
set -eu -o pipefail

# Compile
LIBS="-I include -I $PREFIX/include -L $PREFIX/lib"
CXXFLAGS="-std=c++14 -Wall -Wextra -O3 -g3 -lhts"

make CXX="$CXX" LIBS="$LIBS" CXXFLAGS="$CXXFLAGS"
mkdir -p $PREFIX/bin
mv HmnRandomRead $PREFIX/bin
