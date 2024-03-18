#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p $PREFIX/bin

make CC="${CC} ${LDFLAGS}" CXX="${GXX}" CFLAGS="${CFLAGS} -fcommon"

cp dmtools $PREFIX/bin
cp genome2cg $PREFIX/bin
cp genomebinLen $PREFIX/bin
cp dmalign $PREFIX/bin
cp bam2dm $PREFIX/bin
cp dmDMR $PREFIX/bin
