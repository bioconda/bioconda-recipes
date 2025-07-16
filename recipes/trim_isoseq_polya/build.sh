#!/bin/bash

mkdir build && cd build

cmake \
    -DBOOST_ROOT="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DSUPPORT_COMPRESSED_INPUT=ON \
    ..

make

mkdir -p "${PREFIX}/bin"
cp ../bin/trim_isoseq_polyA "${PREFIX}/bin"
