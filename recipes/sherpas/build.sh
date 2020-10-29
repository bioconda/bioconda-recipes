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
find . -name *.so -print
ls -l lib/xpas
cp lib/xpas/xpas/libxpas_dna.so $PREFIX/lib
cp lib/xpas/utils/libutils.so $PREFIX/lib
chmod +x $PREFIX/bin/SHERPAS
