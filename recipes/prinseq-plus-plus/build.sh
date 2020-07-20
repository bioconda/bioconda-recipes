#!/bin/bash
set +ex

# Add zlib support
export CFLAGS="-I$PREFIX/include"
export CXX_INCLUDE_DIR=$PREFIX/include
export CPP_INCLUDE_DIR=$PREFIX/include
export CPPLUS_INCLUDE_DIR=$PREFIX/include
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


# build
./autogen.sh
./configure
make
make install
