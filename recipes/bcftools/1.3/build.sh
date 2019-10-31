#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make plugins CC=$CC
make prefix=$PREFIX CC=$CC install
