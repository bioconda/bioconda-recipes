#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


# cd to location of Makefile and source
cd $SRC_DIR/gnuac

# depends on automake, autoconf
aclocal
autoheader
automake -a -c
autoconf
./configure --prefix=$PREFIX
make
make install