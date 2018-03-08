#!/bin/bash

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

make

# Link tools to PREFIX
find . -type l | while read a; do cp --copy-contents -LR  "$a" ${PREFIX}/bin; done
