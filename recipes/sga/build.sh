#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CXXFLAGS="-I${PREFIX}/include"

pushd $SRC_DIR/src

./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX --with-sparsehash=$PREFIX
make CC=${CC} CXX=${CXX}
make install
