#!/usr/bin/env bash

set -xe

# Generate build
mkdir -p build
cd build
cmake -DCFLAGS="${CFLAGS}" -DLDFLAGS="${LDFLAGS}" ..

# Build
VERBOSE=1 make -j ${CPU_COUNT} graphtyper

# Install
mkdir -p $PREFIX/bin
cp bin/graphtyper $PREFIX/bin/graphtyper
