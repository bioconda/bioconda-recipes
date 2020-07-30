#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

echo `ls $SRC_DIR`
cd $SRC_DIR  
mkdir -p $SRC_DIR/release-build
cd $SRC_DIR/release-build
cmake ..
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/release-build/sherpas/SHERPAS $PREFIX/bin

