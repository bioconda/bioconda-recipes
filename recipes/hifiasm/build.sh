#!/bin/bash

mkdir -p $PREFIX/bin

make PREFIX=${PREFIX} CC=${CC} CXX=${CXX}
cp hifiasm $PREFIX/bin
