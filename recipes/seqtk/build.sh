#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPLAGS="-I${PREFIX}/include -g -Wall -O2 -Wno-unused-function"
export CFLAGS="$CPPFLAGS"
export LDFLAGS="-L${PREFIX}/lib "
export CPATH="${PREFIX}/include"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS_EXTRA="${LDFLAGS} ${CPPFLAGS}"


make -e all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
