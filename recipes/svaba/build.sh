#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git

for FOLDER in $(find . -type d); do ln -fs $PREFIX/include/zlib.h $FOLDER/zlib.h; done

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure CXXFLAGS=-fPIC --prefix=$PREFIX
make
make install
