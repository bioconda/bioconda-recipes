#!/usr/bin/env bash

mkdir build &&cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DKSIZE_LIST="32 64 96 128 160 192" ..
make
cp $SRC_DIR/bin/dechat $PREFIX
