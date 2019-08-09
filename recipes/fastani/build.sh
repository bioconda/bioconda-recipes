#!/bin/bash

# without these lines, -lz can not be found
export CXXFLAGS="$CXXFLAGS -L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin

./bootstrap.sh
./configure --prefix=$PREFIX --with-boost=$PREFIX

make
make install
