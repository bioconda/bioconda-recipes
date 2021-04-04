#!/bin/bash
set -eux -o pipefail

export gcc=$GCC
export g++=$CXX
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DPRINT_STACKTRACE=True \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..
make VERBOSE=1
ctest -VV
make install
