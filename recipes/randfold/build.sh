#!/bin/bash

gunzip squid.tar.gz
tar xf squid.tar
cd squid-1.9g

./configure --prefix=$PREFIX -q
make clean
make
make install

cd ..

export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"

make
cp randfold $PREFIX/bin

