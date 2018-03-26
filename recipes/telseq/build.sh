#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

export CC=gcc
export CXX=g++

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX
make
make install
