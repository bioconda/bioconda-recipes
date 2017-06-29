#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export CXXFLAGS="-pthread"
export CFLAGS+="-pthread"

make
PREFIX=$PREFIX/bin make install
