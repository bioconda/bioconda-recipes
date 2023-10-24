#!/bin/bash
set -eu -o pipefail

# Compile
LIBS="-I $PREFIX/include -L $PREFIX/lib"
CXXFLAGS="-std=c++14 -O3 -W -Wall -pedantic -lrt -DNDEBUG -DSEQAN_ENABLE_DEBUG=0 -DSEQAN_ENABLE_TESTING=0 -DSEQAN_HAS_ZLIB=1 -lz -DSEQAN_HAS_OPENMP=1 -lgomp -fopenmp -lpthread -lisal -DSEQAN_HAS_IGZIP=1"

make CXX="$CXX" LIBS="$LIBS" CXXFLAGS="$CXXFLAGS"
mkdir -p $PREFIX/bin
mv HmnTrimmer $PREFIX/bin

# Script
cp ./script/HmnTrimmerReport $PREFIX/bin/
chmod +x $PREFIX/bin/HmnTrimmerReport
