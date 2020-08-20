#!/bin/bash


cd src
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CC="${CC} -L${PREFIX}/lib"
./configure
make prefix=${PREFIX} CC="${CC}"

mkdir -p $PREFIX/bin

cp migrate-n $PREFIX/bin

