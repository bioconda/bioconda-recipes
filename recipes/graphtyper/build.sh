#!/usr/bin/env bash

# Generate build
mkdir -p build
cd build
cmake -DCFLAGS="${CFLAGS}" -DLDFLAGS="${LDFLAGS}" ..

# Build
VERBOSE=1 make graphtyper

# Install
mkdir -p $PREFIX/bin
cp bin/graphtyper $PREFIX/bin/graphtyper
