#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
make install
cp ../bin/rapmap $PREFIX/bin
