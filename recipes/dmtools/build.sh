#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CFLAGS="${CFLAGS} -fcommon"
mkdir -p $PREFIX/bin
cp dmtools $PREFIX/bin
cp genome2cg $PREFIX/bin
cp genomebinLen $PREFIX/bin
cp dmalign $PREFIX/bin
cp bam2dm $PREFIX/bin
cp dmDMR $PREFIX/bin
