#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

ls -l
cmake --build .
mkdir release-build
cd release-build
cmake --build .. --target SHERPAS
make

cp sherpas/SHERPAS $PREFIX/bin
chmod +x $PREFIX/bin/SHERPAS
