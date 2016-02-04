#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

