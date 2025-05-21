#!/bin/bash

set -xe

export CXXFLAGS=`sed "s# -fvisibility-inlines-hidden##g" "$CXXFLAGS"`

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DTBB_LIB_DIR="${PREFIX}/lib" \
    -DTBB_INCLUDE_DIR="${PREFIX}/include" \
    ./src
cmake --build build -j"${CPU_COUNT}" -v

install -d "${PREFIX}/bin"
install -v -m 0755 \
    build/graphconstructor/twopaco \
    build/graphdump/graphdump \
    "${PREFIX}/bin/"
