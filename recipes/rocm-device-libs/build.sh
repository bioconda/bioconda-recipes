#!/bin/bash
set -ex

cd "$SRC_DIR/amd/device-libs"

mkdir -p build

cd build

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DROCM_VERSION="$PKG_VERSION" \
      -DBUILD_DOCS=OFF \
      -DROCM_PATH="$PREFIX" \
      -DCMAKE_PREFIX_PATH="$BUILD_PREFIX" \
      -DZLIB_ROOT="$BUILD_PREFIX" \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      "$SRC_DIR/amd/device-libs"

make -j"$(nproc)"

make install

