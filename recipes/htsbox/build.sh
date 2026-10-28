#!/bin/bash
set -xe

#strictly use anaconda build environment
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 htsbox "$PREFIX/bin"
