#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
