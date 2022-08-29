#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cmake .
mkdir release-build
pushd release-build
cmake --build .. --target SHERPAS
ls ../
popd
ls sherpas

cp sherpas/SHERPAS $PREFIX/bin
chmod +x $PREFIX/bin/SHERPAS
