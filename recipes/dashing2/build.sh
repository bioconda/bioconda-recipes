#!/bin/bash

mkdir -p "${PREFIX}/bin"

export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -D_GNU_SOURCE"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXSTD="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 dashing2 dashing2-64 dashing2-tmp "${PREFIX}/bin"
