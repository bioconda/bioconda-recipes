#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir release-build
cd release-build
cmake ..
make

cp sherpas/SHERPAS $PREFIX/bin
cp sherpas/libxpas_dna.so $PREFIX/lib
chmod +x $PREFIX/bin/SHERPAS
