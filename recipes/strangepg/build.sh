#!/bin/bash -eu

set -xe

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="$LDFLAGS -ldl -lpthread -L${PREFIX}/lib"
export CFLAGS="$CFLAGS -O3 -I${PREFIX}/include"

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" PREFIX="${PREFIX}" -j"${CPU_COUNT}" install
