#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX
make
make install

mv sparsetable_unittest  $PREFIX/bin
