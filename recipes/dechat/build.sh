#!/usr/bin/env bash

cd $SRC_DIR
mkdir build &&cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX  ..
make
cp $SRC_DIR/bin/dechat $PREFIX
