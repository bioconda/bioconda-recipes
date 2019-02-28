#!/usr/bin/env bash

set -eu -o pipefail

mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_LIBRARY_PATH=${PREFIX}/lib \
  -DCMAKE_INCLUDE_PATH=${PREFIX}/include ..

make 
make install
