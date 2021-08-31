#!/bin/sh

export CPATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

rm -rf build
mkdir -p build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX
make -j $CPU_COUNT

make install
