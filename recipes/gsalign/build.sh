#!/bin/bash
mkdir -p ${PREFIX}/bin

# index
pushd src/BWT_Index
make CC=$CC FLAGS="$CFLAGS" LIBS="$LDFLAGS -lm -lz"
cp bwt_index $PREFIX/bin
popd

# GSAlign
pushd src
make CXX=$CXX FLAGS="$CXXFLAGS -I$PREFIX/include -Wall -D NDEBUG -O3 -m64 -msse4.2 -mpopcnt -fPIC" LIB="$LDFLAGS -lz -lm -lpthread"
cp GSAlign $PREFIX/bin
