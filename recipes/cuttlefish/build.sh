#!/bin/bash

mkdir build
cd build

# hack! because bzip2 is broken.
CC="${CC} -I ${PREFIX}/include" CXX="${CXX} -I ${PREFIX}/include" cmake \
    -DINSTANCE_COUNT=64 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCONDA_BUILD=ON \
    ..
make install
