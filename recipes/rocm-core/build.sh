#!/bin/bash

set -ex

mkdir -p build

cd build

cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DROCM_VERSION="$PKG_VERSION" \
      -DBUILD_DOCS=OFF \
      ..

make -j$(nproc)

make install
