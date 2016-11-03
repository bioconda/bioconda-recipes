#!/bin/bash
set -x
set -e
pushd $SRC_DIR/src

export CPATH=${PREFIX}/include

./autogen.sh
./configure --prefix=$PREFIX --with-jemalloc=$PREFIX/lib --with-sparsehash=$PREFIX --with-bamtools=$PREFIX && make && make install
