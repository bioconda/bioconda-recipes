#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

mkdir build
cd build
cmake ..

make -j ${CPU_COUNT}

cp ./bin/metaMDBG $PREFIX/bin
