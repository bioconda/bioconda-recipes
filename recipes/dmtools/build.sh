#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CXX=$CXX CPP=$CXX CC=$CC
#CFLAGS="${CFLAGS} -fcommon"
#LDFLAGS=""
#make CXX=$CXX CPP=$CXX CC=$CC LDLIBS="-L$PREFIX/lib -lz -lzstd -ltbb -ltbbmalloc -lpthread" WITH_ZSTD=1

mkdir -p $PREFIX/bin
cp dmtools $PREFIX/bin
cp genome2cg $PREFIX/bin
cp genomebinLen $PREFIX/bin
cp dmalign $PREFIX/bin
cp bam2dm $PREFIX/bin
cp dmDMR $PREFIX/bin
