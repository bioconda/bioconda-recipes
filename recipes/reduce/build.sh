#!/bin/bash

mkdir -p build
cd build
cmake ${SRC_DIR} -DCMAKE_INSTALL_PREFIX=${PREFIX}
make
make install
