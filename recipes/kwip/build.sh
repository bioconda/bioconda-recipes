#!/bin/bash

export BINARY_HOME=$PREFIX

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd $SRC_DIR
sed -i -e 's/-march=native//' CMakeLists.txt
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${BINARY_HOME}
make
ctest
make install
