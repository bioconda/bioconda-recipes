#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR/build 

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath $PREFIX/lib"

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

