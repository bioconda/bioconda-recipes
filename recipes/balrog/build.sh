#!/bin/bash

export CPATH=${PREFIX}/include

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ..
cmake --build . --target Balrog -- -j 3
make install