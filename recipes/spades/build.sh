#!/bin/bash
mkdir -p $PREFIX/bin
mkdir build
cd build

cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" ../src
make 
make install
