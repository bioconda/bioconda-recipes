#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure CXXFLAGS=-fPIC --prefix=$PREFIX
make
make install
