#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/bin

# index
pushd src/BWT_Index
make CC=$CC FLAGS="$CFLAGS" LIBS="$LDFLAGS -lm -lz"
cp bwt_index $PREFIX/bin
popd

ARCH_FLAGS=""
case $(uname -m) in
    x86_64)
        ARCH_FLAGS="-m64 -msse4.2 -mpopcnt"
        ;;
    *)
        ;;
esac

# GSAlign
pushd src
make CXX=$CXX FLAGS="$CXXFLAGS -I$PREFIX/include -Wall -D NDEBUG -O3 ${ARCH_FLAGS} -fPIC" LIB="$LDFLAGS -lz -lm -lpthread" -j ${CPU_COUNT}
cp GSAlign $PREFIX/bin
