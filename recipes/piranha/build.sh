#!/bin/sh

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

./configure && \
make && \
make test && \
make install

cp bin/* $PREFIX/bin
