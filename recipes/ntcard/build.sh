#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CXXFLAGS="$CXXFLAGS -Wno-array-bounds"

export M4="$BUILD_PREFIX/bin/m4"

sh autogen.sh
./configure --prefix=$PREFIX
make
make install


