#!/bin/sh

set -e -u -x

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX/bin --enable-threads --enable-altivec --enable-debugging=3
make
make install
