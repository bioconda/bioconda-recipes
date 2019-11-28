#!/bin/sh

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -j8

cp bin/Bloocoo $PREFIX/bin
