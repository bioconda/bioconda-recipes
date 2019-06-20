#!/bin/bash

if [[ $OSTYPE == "linux-gnu" ]]; then
	cmake -Wno-dev -G "Unix Makefiles" -DOPENCL_LIBRARY=${PREFIX}/lib/libOpenCL.so -DOPENCL_INCLUDE_DIR=${PREFIX}/include
elif [[ $OSTYPE == "darwin"* ]]; then
	cmake -Wno-dev -G "Unix Makefiles"
fi
make
mkdir -p $PREFIX/bin
cp cas-offinder $PREFIX/bin
