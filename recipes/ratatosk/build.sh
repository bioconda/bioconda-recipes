#!/bin/bash
set -x

mkdir -p $PREFIX/bin
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/bin ..
make
make install