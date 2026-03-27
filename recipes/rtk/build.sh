#!/bin/bash

mkdir -p "${PREFIX}/bin"

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

echo "Compiling RTK"
cd rtk && make -j"${CPU_COUNT}"

echo "Installing binary"
install -v -m 0755 rtk "${PREFIX}/bin"
