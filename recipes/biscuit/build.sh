#!/bin/bash

# Needed for building utils dependency
export CPATH=${PREFIX}/include

mkdir -p "${PREFIX}/bin"
mkdir -p build
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
make CC=$CC
make install
