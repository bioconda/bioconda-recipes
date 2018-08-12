#!/bin/sh

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CPLUS_INCLUDE_PATH=$PREFIX/include

mkdir -p $PREXIX/bin
make
cp lighter $PREFIX/bin

