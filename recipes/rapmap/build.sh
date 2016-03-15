#!/bin/bash
mkdir build && cd build
cmake ..
make
make install
mkdir -p $PREFIX/bin
cp ../bin/rapmap $PREFIX/bin
