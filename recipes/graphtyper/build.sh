#!/usr/bin/env bash

# Generate build
mkdir -p build
cd build
cmake -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON ..

# Build
VERBOSE=1 make graphtyper

# Install
mkdir -p $PREFIX/bin
cp bin/graphtyper $PREFIX/bin/graphtyper
