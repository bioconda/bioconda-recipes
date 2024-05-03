#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

##echo make CXX=$CXX CPP=$CXX CC=$CC CFLAGS="-g -w -O3 -Wsign-compare -I$BUILD_PREFIX/include"
make CXX=$CXX CPP=$CXX CC=$CC
#CFLAGS="-g -w -O3 -Wsign-compare -I$PREFIX/include -L$PREFIX/lib"
##export CFLAGS="-I$BUILD_PREFIX/include"
##export LDFLAGS="-L$BUILD_PREFIX/lib"
##CFLAGS="${CFLAGS} -fcommon"
##LDFLAGS=""
##make CXX=$CXX CPP=$CXX CC=$CC LDLIBS="-L$PREFIX/lib -lz -lzstd -ltbb -ltbbmalloc -lpthread" WITH_ZSTD=1

mkdir -p $PREFIX/bin
cp dmtools $PREFIX/bin
cp genome2cg $PREFIX/bin
cp genomebinLen $PREFIX/bin
cp dmalign $PREFIX/bin
cp bam2dm $PREFIX/bin
cp dmDMR $PREFIX/bin
cp libBinaMeth.so $PREFIX/lib
