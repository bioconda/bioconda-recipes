#!/bin/bash

BINARY_HOME=$PREFIX/bin

cd $SRC_DIR
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${BINARY_HOME}
make
make test
make install