#!/bin/bash

mkdir -p "$PREFIX/bin"

mkdir build
cd build
cmake  -D CMAKE_INSTALL_PREFIX=${PREFIX} ..
make
cp assembly-stats $PREFIX/bin

