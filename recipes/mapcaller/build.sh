#!/bin/bash

# index
pushd src/BWT_Index
make CC=$CC FLAGS="$CFLAGS" LIBS="$LDFLAGS -lm -lz" libbwa.a
popd

#htslib
pushd src/htslib
make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" libhts.a
popd

#Mapcaller
pushd src
make CXX=$CXX FLAGS="$CXXFLAGS -Wall -D NDEBUG -O3 -m64 -msse4.1 -fPIC" LIB="$LDFLAGS -lz -lm -lbz2 -llzma -lpthread"
mkdir -p ${PREFIX}/bin
cp MapCaller ${PREFIX}/bin
