#!/bin/sh

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

./configure --prefix=$PREFIX && \
make && \
make test && \
make install
