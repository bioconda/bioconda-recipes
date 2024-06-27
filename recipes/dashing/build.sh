#!/bin/bash

set -xe

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

pushd bonsai
rm -rf zstd
git clone --recursive --single-branch --branch dev https://github.com/facebook/zstd
pushd zstd
make -j ${CPU_COUNT} CC=$CC lib && mv lib/libzstd.a ..
popd
popd

sed -i.bak "s/ -lzstd//g" Makefile
make -j ${CPU_COUNT} CC=$CC CXX=$CXX
make install PREFIX=$PREFIX
