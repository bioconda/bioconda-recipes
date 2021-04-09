#!/usr/bin/env bash

# Generate build
mkdir -p build
cd build
cmake -DCFLAGS="${CFLAGS}" -DLDFLAGS="${LDFLAGS}" -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_USE_STATIC_LIBS=OFF ..

# Build
VERBOSE=1 make graphtyper

# Install
mkdir -p $PREFIX/bin
cp bin/graphtyper $PREFIX/bin/graphtyper
