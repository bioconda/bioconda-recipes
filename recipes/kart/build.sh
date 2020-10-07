#!/bin/bash
mkdir -p ${PREFIX}/bin

#index
pushd src/BWT_Index
make CC=$CC FLAGS="$CFLAGS" LIBS="$LDFLAGS -lm -lz"
cp bwt_index $PREFIX/bin
popd

#htslib
pushd src/htslib
make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" libhts.a
popd

#kart
pushd src
make CXX=$CXX FLAGS="$CXXFLAGS -Wall -D NDEBUG -O3 -m64 -msse4.1 -fPIC" LIB="$LDFLAGS -lz -lm -lbz2 -llzma -lpthread"
cp kart $PREFIX/bin

