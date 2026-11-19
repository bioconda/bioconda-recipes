#!/bin/bash
set -euxo pipefail

TP="${SRC_DIR}/third_party"

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_IGNORE_PREFIX_PATH="/opt/homebrew;/usr/local" \
    -DOpenMP_ROOT="${PREFIX}" \
    -DBAYSOR_WITH_TESTS=OFF \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DFETCHCONTENT_SOURCE_DIR_AARAND="${TP}/aarand" \
    -DFETCHCONTENT_SOURCE_DIR_KMEANS="${TP}/kmeans" \
    -DFETCHCONTENT_SOURCE_DIR_SUBPAR="${TP}/subpar" \
    -DFETCHCONTENT_SOURCE_DIR_KNNCOLLE="${TP}/knncolle" \
    -DFETCHCONTENT_SOURCE_DIR_IRLBA="${TP}/irlba" \
    -DFETCHCONTENT_SOURCE_DIR_UMAPPP="${TP}/umappp"

cmake --build build --target baysor -j"${CPU_COUNT}"
cmake --install build --prefix "${PREFIX}"
