#!/bin/bash

set -xe

export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
cd src/cpp

make BINPATH="${PREFIX}/bin" CPPFLAGS="${CPPFLAGS}" -j"${CPU_COUNT}"
