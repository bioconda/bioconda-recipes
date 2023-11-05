#!/bin/bash

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-mavx2 -D__STDC_FORMAT_MACROS" -DRAPTOR_NATIVE_BUILD=OFF -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j"${CPU_COUNT}"
make install
