#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

export LIBS="-lpthread $LIBS"
export CXXFLAGS="-pthread -std=c++11"

mkdir -p $PREFIX/bin

autoconf
./configure --prefix=$PREFIX --enable-multithreading
make
make install 
