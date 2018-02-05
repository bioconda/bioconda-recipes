#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

CC_=$CC
CXX_=$CXX

source source_me.sh

# overwrite CC and CXX from source_me.sh
# use conda binaries instead
export CC=$CC_
export CXX=$CXX_

make static

mkdir -p $PREFIX/bin
cp bin/vg $PREFIX/bin
