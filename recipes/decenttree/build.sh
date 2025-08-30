#!/bin/bash
set -euo pipefail

mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT:-1}

# Move binary into $PREFIX/bin
mkdir -p $PREFIX/bin
cp decenttree $PREFIX/bin/
