#!/usr/bin/env bash
set -euxo pipefail

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT}
install -Dm755 decenttree $PREFIX/bin/decenttree
