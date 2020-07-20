#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" PREFIX=${PREFIX} CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
