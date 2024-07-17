#!/bin/bash

set -xe

export CXX="$CXX"
export LINKER="$CXX"

# GCLIB needs gcc to detect its version
# GCLIB itself is git-cloned by gffcompare's Makefile
ln -s ${CC} $BUILD_PREFIX/bin/gcc

mkdir -p "$PREFIX"/bin/
make -j ${CPU_COUNT} release
cp gffcompare "$PREFIX"/bin/
cp trmap "$PREFIX"/bin/

unlink $BUILD_PREFIX/bin/gcc