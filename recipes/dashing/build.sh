#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

pushd bonsai
git clone --recursive --single-branch --branch dev https://github.com/facebook/zstd
pushd zstd
make CC=$CC lib && mv lib/libzstd.a ..
popd
popd

sed -i.bak "s/ -lzstd//g" Makefile
make CC=$CC CXX=$CXX
make install PREFIX=$PREFIX
