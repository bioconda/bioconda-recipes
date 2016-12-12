#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"


export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/bin

cp -rf scripts/* $PREFIX/bin/
