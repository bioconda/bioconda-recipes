#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR/build 

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

