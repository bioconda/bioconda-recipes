#!/bin/bash
set -euo pipefail

mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DGENESIS_BUILD_SHARED_LIB=ON \
    -DGENESIS_BUILD_STATIC_LIB=OFF \
    -DGENESIS_BUILD_APPLICATIONS=OFF \
    -DGENESIS_BUILD_TESTS=OFF \
    -DGENESIS_BUILD_PYTHON_MODULE=OFF \
    -DGENESIS_USE_OPENMP=OFF \
    -DGENESIS_USE_ZLIB=ON \
    -DGENESIS_USE_HTSLIB=ON \
    -DGENESIS_UNITY_BUILD=FULL

make -j "${CPU_COUNT}"

# Install shared library (output goes to $SRC_DIR/bin/)
mkdir -p "${PREFIX}/lib"
cp "${SRC_DIR}/bin/libgenesis${SHLIB_EXT}" "${PREFIX}/lib/"

# Install headers (preserve directory structure)
mkdir -p "${PREFIX}/include/genesis"
cd "${SRC_DIR}/lib/genesis"
find . \( -name '*.hpp' -o -name '*.tpp' \) -exec install -Dm644 {} "${PREFIX}/include/genesis/{}" \;