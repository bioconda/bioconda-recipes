#!/bin/bash

set -ex

cd "$SRC_DIR/amd/device-libs"

mkdir -p build

cd build

cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      "$SRC_DIR/amd/device-libs"

ninja -j"$(nproc)"

ninja install

