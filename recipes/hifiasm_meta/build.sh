#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} INCLUDES="-I$PREFIX/include" CXXFLAGS="-L$PREFIX/lib" CC=${CC} CXX=${CXX}
cp hifiasm_meta $PREFIX/bin
