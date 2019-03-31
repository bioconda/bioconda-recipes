#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git

ln -s $PREFIX/include/zlib.h SeqLib/bwa/

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure CXXFLAGS=-fPIC --prefix=$PREFIX
make
make install
