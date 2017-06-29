#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

cmake . -DPYTHON_BINDINGS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
