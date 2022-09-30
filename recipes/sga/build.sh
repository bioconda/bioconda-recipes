#!/bin/bash

export CFLAGS="-I$PREFIX/include -O3"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include -O3"

pushd $SRC_DIR/src

./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX --with-sparsehash=$PREFIX
make
make install
