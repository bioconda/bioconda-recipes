#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -lz -lpthread -lm" CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
