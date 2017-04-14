#!/bin/bash

export CPATH=${PREFIX}/include

./configure --prefix=$PREFIX --enable-sparsehash --enable-bam --includedir=${PREFIX}/include/bam --libdir=${PREFIX}/lib
cp Makefile Makefile.bk
sed "s|^LIBS=.*$|LIBS=\"-I$PREFIX/include/ -L$PREFIX/lib/ -lz -lgomp\"|" Makefile.bk > Makefile
make
make install
