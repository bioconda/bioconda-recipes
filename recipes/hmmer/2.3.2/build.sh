#!/bin/sh

set -e -u -x

./configure --prefix=$PREFIX --enable-threads --enable-debugging=3
make
make install

ls -l $PREFIX/bin
