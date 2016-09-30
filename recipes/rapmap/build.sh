#!/bin/bash
mkdir build && cd build
cmake -DNO_NATIVE_ARCH=TRUE -DCMAKE_CXX_FLAGS=-mno-avx ..
make
make install
mkdir -p $PREFIX/bin
cp ../bin/rapmap $PREFIX/bin
