#!/bin/bash

gunzip squid.tar.gz
tar xf squid.tar
cd squid-1.9g

./configure --prefix=$PREFIX -q
make clean
make
make install

cd ..

make
cp randfold $PREFIX/bin

