#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

make bin/GraphAligner CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/GraphAligner "${PREFIX}/bin"
