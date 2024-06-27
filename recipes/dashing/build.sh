#!/bin/bash

set -xe

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak "s/ -lzstd//g" Makefile
make -j ${CPU_COUNT} CC=$CC CXX=$CXX
make install PREFIX=$PREFIX
