#!/bin/bash

make clean
make CPP=$GXX LIBRARY_PATH=${PREFIX}/lib INCLUDE_PATH=${PREFIX}/include all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
