#!/bin/bash
set -ex

mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" \
    ..
make

# Install
mkdir $PREFIX/bin
cp BandageNG $PREFIX/bin/Bandage
