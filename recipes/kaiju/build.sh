#!/bin/bash


export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin

cd $SRC_DIR/src/

make CC=${CC} CXX=${CXX} -j ${CPU_COUNT}

cd $SRC_DIR/bin/
cp kaiju* $PREFIX/bin
