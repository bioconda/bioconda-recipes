#!/bin/sh

set -e -u -x

ls -l $PREFIX/bin

./configure --prefix=$PREFIX --enable-threads --enable-debugging=3
make
make install

ls -l $PREFIX/bin
