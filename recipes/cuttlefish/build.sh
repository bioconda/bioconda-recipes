#!/bin/bash

mkdir build
cd build

mkdir -p ../external/include

cp ${PREFIX}/include/bzlib.h ../external/include/
cp ${PREFIX}/include/zlib.h ../external/include/

# hack! because bzip2 is broken.
cmake \
    -DINSTANCE_COUNT=64 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCONDA_BUILD=ON \
    ..
make install
