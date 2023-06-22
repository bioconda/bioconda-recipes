#! /bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir build
cd build
cmake ..
make
mkdir -p $PREFIX/bin
cp derna $PREFIX/bin
