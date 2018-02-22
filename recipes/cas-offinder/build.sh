#!/bin/bash

cmake -Wno-dev -G "Unix Makefiles" -DOPENCL_LIBRARY=$PREFIX/lib/libOpenCL.so.1 -DOPENCL_INCLUDE_DIR=$PREFIX/include
make

mkdir -p $PREFIX/bin
cp cas-offinder $PREFIX/bin
