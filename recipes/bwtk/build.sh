#!/bin/bash

set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

make CC="${CC}" CFLAGS="${CFLAGS}" PREFIX="${PREFIX}" z_dyn=1 bw_dyn=1 release -j"${CPU_COUNT}"
make install
