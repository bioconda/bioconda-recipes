#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# add biomcmc-lib to proper location and run autoreconf
cd $SRC_DIR
sh ./autogen.sh
# cd to location of Makefile and source
mkdir build
cd build
# assumes autoreconf was run and thus configure.sh is present
$SRC_DIR/configure --prefix=$PREFIX
make
make install

