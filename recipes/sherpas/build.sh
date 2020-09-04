#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin

mkdir release-build
cd release-build
cmake ..
make

cp sherpas/SHERPAS $PREFIX/bin
chmod +x $PREFIX/bin/SHERPAS
