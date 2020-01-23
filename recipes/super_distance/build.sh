#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# cd to location of Makefile and source
mkdir build
cd build
# assumes autoreconf was run and thus configure.sh is present
$SRC_DIR/configure --prefix=$PREFIX
make
make install

