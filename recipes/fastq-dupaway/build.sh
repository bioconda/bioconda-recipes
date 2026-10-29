#!/bin/bash

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j${CPU_COUNT}

mkdir -p $PREFIX/bin
mv fastq-dupaway $PREFIX/bin/
