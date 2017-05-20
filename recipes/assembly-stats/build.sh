#!/bin/bash

mkdir -p "$PREFIX/bin"

mkdir build
cd build
cmake  -D CMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make test
make install
