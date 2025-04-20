#!/usr/bin/env bash
set -euo pipefail

mkdir build
cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=${CXX}

make -j${CPU_COUNT}
make install
