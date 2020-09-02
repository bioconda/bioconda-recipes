#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

# for troubleshooting with zlib
export CPATH=${PREFIX}/include

# cp executables
mkdir -p $PREFIX/bin
cp -pf CRAC $PREFIX/bin

# compile Crac 
./configure
make clean
make -B CFLAGS=-DNDEBUG