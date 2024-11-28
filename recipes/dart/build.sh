#!/bin/bash
mkdir -p ${PREFIX}/bin

ARCH_BUILD="-m64 -msse4.1"
case $(uname -m) in
    arm64|aarch64) ARCH_BUILD="" ;;
esac

#index
pushd src/BWT_Index
make CC=$CC FLAGS="$CFLAGS" LIBS="$LDFLAGS -lm -lz"
cp bwt_index $PREFIX/bin
popd

#htslib
pushd src/htslib
make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" libhts.a
popd

#dart
pushd src
make CXX=$CXX FLAGS="$CXXFLAGS -Wall -D NDEBUG -O3 $ARCH_BUILD -fPIC" LIB="$LDFLAGS -lz -lm -lbz2 -llzma -lpthread"
cp dart $PREFIX/bin

