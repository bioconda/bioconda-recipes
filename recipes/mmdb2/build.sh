#!/bin/bash

set -euxo pipefail

# Configure
./configure \
    --prefix=${PREFIX} \
    --enable-shared \
    --disable-static

# Build
make -j${CPU_COUNT}

# Install
make install
