#!/bin/bash
ls -l
# Add zlib support
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


# build
./autogen.sh
./configure
make
make install
