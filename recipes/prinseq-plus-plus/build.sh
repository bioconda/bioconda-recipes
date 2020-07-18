#!/bin/bash

# Add zlib support
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


# build
./autogen.sh
./configure --prefix=$PREFIX
make
make install
