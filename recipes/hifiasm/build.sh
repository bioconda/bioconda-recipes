#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" CXXFLAGS="-L$PREFIX/lib" CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
