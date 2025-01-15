#!/usr/bin/env bash

set -xeu -o pipefail

mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_LIBRARY_PATH=${PREFIX}/lib \
  -DCMAKE_INCLUDE_PATH=${PREFIX}/include ..

make -j1
make install
