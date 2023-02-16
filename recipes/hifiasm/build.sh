#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -lz" CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
