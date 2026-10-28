#!/bin/bash

mkdir -p "${PREFIX}/bin"

cd "source"

sed -i.bak 's/VERSION 2.8/VERSION 3.5/g' CMakeLists.txt
rm -f *.bak

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_TYPE=Release \
    -DITK_DIR="${PREFIX}/lib"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/EvaluateSegmentation "${PREFIX}/bin"
