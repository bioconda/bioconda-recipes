#!/bin/sh

set -e -u -x

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX/bin --enable-threads
make
make install
