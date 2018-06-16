#!/usr/bin/env bash

set -x -e


export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

pushd $SRC_DIR

autoreconf -fi -Im4
./configure --prefix=$PREFIX
cat Makefile
make
make install
