#!/bin/bash
set -x -e

export CFLAGS="${CFLAGS} -I${PREFIX}/include -I${PREFIX}/include/htslib -ldl -ldeflate -fno-strict-aliasing"
#export LDFLAGS="-ldl"
export CXXFLAGS="${CXXFLAGS} -ldl -ldeflate"
export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/htslib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
autoreconf -vfi

CXXFLAGS="-I${PREFIX}/htslib ${CXXFLAGS}" ./configure --prefix=${PREFIX}
CXXFLAGS="${CXXFLAGS}" PREFIX=${PREFIX} make
make install
