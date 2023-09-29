#!/bin/bash
set -ex

mkdir -p build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" \
    ..
make

# Install
mkdir -p $PREFIX/bin
cp BandageNG $PREFIX/bin/Bandage
