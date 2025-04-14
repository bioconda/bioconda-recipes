#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export CXXFLAGS="${LDFLAGS} ${CPPFLAGS}"

mkdir -p $PREFIX/bin

make

cp SOAPdenovo-127mer $PREFIX/bin
cp SOAPdenovo-63mer $PREFIX/bin
