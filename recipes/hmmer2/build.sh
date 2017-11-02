#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

# Fix broken configure option
./configure  --prefix=$PREFIX
make
make install --always-make