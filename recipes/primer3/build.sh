#!/bin/bash

set -xe

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cd src
make -j ${CPU_COUNT} CC=$CC CXX=$CXX
make PREFIX=${PREFIX} CC=$CC CXX=$CXX install
