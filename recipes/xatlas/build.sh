#!/bin/bash

export LIBS="-lpthread $LIBS"
export CXXFLAGS="-pthread -std=c++11"

mkdir -p $PREFIX/bin

autoconf
./configure --prefix=$PREFIX --enable-multithreading
make
make install 