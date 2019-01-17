#!/bin/bash
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export BINARY_HOME=$PREFIX

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd $SRC_DIR
mkdir build && cd build
cmake .. \
	-DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${BINARY_HOME}
make
ctest --verbose
make install
