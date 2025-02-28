#!/bin/sh

set -xe

# for OSX ARM64
export M4="$BUILD_PREFIX/bin/m4"

./bootstrap
./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
