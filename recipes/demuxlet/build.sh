#!/bin/bash
set -x -e

export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/htslib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -I${PREFIX}/include/htslib -ldl -ldeflate -fno-strict-aliasing"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/htslib -ldl -ldeflate"

autoreconf -if
CXXFLAGS="${CXXFLAGS}" ./configure --prefix="${PREFIX}"

CXXFLAGS="${CXXFLAGS}" PREFIX="${PREFIX}" make -j"${CPU_COUNT}"
make install
