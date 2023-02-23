#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" CXXFLAGS="-L$PREFIX/lib -g -O3 -msse4.2 -mpopcnt -fomit-frame-pointer -Wall" CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
