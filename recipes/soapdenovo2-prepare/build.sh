#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export ARCHFLAGS="-Wno-error=unused-command-line-argument-hard-error-in-future"

mkdir -p $PREFIX/bin

make
make all

cp finalFusion $PREFIX/bin
