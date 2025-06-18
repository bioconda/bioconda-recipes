#!/bin/bash

mkdir -p "${PREFIX}/bin"

export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/bam"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

./install_deps.sh

make install CC="${CC}" -j"${CPU_COUNT}"

install -v -m 755 bin/* "${PREFIX}/bin"
