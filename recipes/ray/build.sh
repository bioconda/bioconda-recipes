#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
export MPICXX=$PREFIX/bin
cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX/bin ..
make
cp Ray $PREFIX/bin
