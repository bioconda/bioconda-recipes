#!/bin/bash

set -eux

mkdir -p build
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-interference-size -D__STDC_FORMAT_MACROS" \
                -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j"${CPU_COUNT}"
make install

chmod +x "${PREFIX}/bin/dream-stellar"
