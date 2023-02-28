#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin
cd hs-blastn-src
make GNU_TOOLCHAIN_PREFIX="${GCC%gcc}" EXTRA_CFLAGS="${CFLAGS}"
cp hs-blastn $PREFIX/bin
