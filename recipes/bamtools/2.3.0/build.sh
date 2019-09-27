#!/bin/bash

mkdir -p build
cd build
export CPLUS_INCLUDE_PATH=${PREFIX}/include
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
