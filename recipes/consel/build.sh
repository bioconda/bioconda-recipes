#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cd src

make CC="${CC}" CFLAGS="${CFLAGS} -O3 -std=gnu89 -Wno-old-style-definition" -j"${CPU_COUNT}"
make install bindir="${PREFIX}/bin"
