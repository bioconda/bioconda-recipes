#!/bin/bash
set -eu -o pipefail

git clone --single-branch --recursive -b "$version" https://github.com/rmcolq/pandora.git

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DPRINT_STACKTRACE=True \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..
make VERBOSE=1
ctest -VV
make install
