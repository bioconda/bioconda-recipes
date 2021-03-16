#!/bin/bash
set -eu -o pipefail

git clone https://github.com/leoisl/gatb-core thirdparty/gatb-core

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release \
      -DPRINT_STACKTRACE=True \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..

make VERBOSE=1
make install
