#!/bin/bash
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++
BINARY_HOME=$PREFIX/bin

cd $SRC_DIR
mkdir build && cd build
cmake .. \
	-DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${BINARY_HOME}
make
ctest --verbose
make install