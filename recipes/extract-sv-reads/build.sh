#!/bin/bash
mkdir -p build
cd build
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHTSLIB_USE_LIBCURL=1 \
    -DHTSLIB_USE_LZMA=1 \
    -DHTSLIB_USE_BZ2=1 \
    ..
make
make install
