#!/bin/bash

./configure --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX
# Add back-compatible links for htslib.so
cd $PREFIX/lib
ln -s libhts.so libhts.so.1
