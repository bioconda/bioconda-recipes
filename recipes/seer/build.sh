#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CXXFLAGS="-std=c++11 -stdlib=libc++ $CXXFLAGS"

cd gzstream && make

cd ..
make
make test
make install
