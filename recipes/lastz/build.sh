#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

sed -i.bak -e 's|gcc|${CC}|' src/Makefile
rm -rf src/*.bak

make CC="${CC}" clean
# Build lastz and lastz_D (lastz_D uses floating-point scores
make CC="${CC}" -j"${CPU_COUNT}"
# Build lastz_32, which uses 32-bit and 40-bit positions indices and can handle genomes larger than 2Gb and 8Gb, respectively.
make CC="${CC}" -j"${CPU_COUNT}" lastz_32 lastz_40

install -v -m 0755 src/lastz src/lastz_D src/lastz_32 src/lastz_40 "${PREFIX}/bin"
