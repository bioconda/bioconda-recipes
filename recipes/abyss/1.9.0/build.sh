#!/bin/bash

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

