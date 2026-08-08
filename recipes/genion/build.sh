#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"
export CONDA_PREFIX="${PREFIX}"

make CXX="${CXX}" OPT="-O3 -I${PREFIX}/include" -j"${CPU_COUNT}"

install -v -m 0755 genion "${PREFIX}/bin"
