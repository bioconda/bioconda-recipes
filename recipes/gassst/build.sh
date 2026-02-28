#!/bin/bash
# export CPPFLAGS="-I${BUILD_PREFIX}/include"

export INCLUDE_PATH="${BUILD_PREFIX}/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${BUILD_PREFIX}/lib"
export CFLAGS=" -Wall -O3 -D_REENTRANT -msse2 -mssse3  -Wno-write-strings -DSSE=3 -std=c++11 --debug"
export LDFLAGS=" -lm -Xlinker -zmuldefs -lpthread -O3 -mssse3 -L${BUILD_PREFIX}/lib"

make CC=$CXX LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"

mkdir -p "$PREFIX"/bin
cp Gassst "$PREFIX"/bin/Gassst
