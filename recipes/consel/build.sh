#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

cd src

make CC="${CC}" CFLAGS="${CFLAGS} -O3 -std=gnu99 -Wno-old-style-definition" -j"${CPU_COUNT}"
make install bindir="${PREFIX}/bin"
