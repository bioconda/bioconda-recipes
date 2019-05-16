#!/bin/bash

make clean
make CC=$CC CXX=$CXX all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
