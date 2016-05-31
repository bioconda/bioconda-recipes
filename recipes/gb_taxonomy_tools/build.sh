#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake -D INSTALL_PREFIX:PATH=$PREFIX ..
make install
