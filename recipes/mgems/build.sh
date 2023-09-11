#!/bin/sh

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
make -j${CPU_COUNT} ${VERBOSE_AT}

cp bin/mGEMS $PREFIX/bin
