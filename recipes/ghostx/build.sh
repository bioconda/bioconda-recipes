#!/usr/bin/env bash
set -xe

export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

cd src

# CC_FLAGS replaces COMMON_FLAGS in the Makefile, so keep -fopenmp (multithreading with -a) and -O3 from there.
CC="${CC}" CXX="${CXX}" CC_FLAGS="${CFLAGS} -fopenmp -O3" make -j"${CPU_COUNT}"

install -v -m 0755 ghostx "$PREFIX/bin"
