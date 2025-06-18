#!/bin/bash

mkdir -p "${PREFIX}/bin"

export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/bam"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"

./install_deps.sh

make install CC="${CC}" -j"${CPU_COUNT}"

install -v -m 755 bin/* "${PREFIX}/bin"
