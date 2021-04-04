#!/bin/bash
set -eux -o pipefail

export CC=$GCC
echo $CC
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DPRINT_STACKTRACE=True \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..
make VERBOSE=1
ctest -VV
make install
