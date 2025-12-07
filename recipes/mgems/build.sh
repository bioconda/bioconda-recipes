#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
make -j${CPU_COUNT} ${VERBOSE_AT}

chmod 755 bin/mGEMS
cp -f bin/mGEMS $PREFIX/bin
