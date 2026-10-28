#!/bin/bash
set -xeu -o pipefail
mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

make CXX="${CXX}" \
    INCLUDE_DIRS="$PREFIX/include" \
    LIBRARY_DIRS="$PREFIX/lib" \
    LD_FLAGS="-L${PREFIX}/lib -lisal -ldeflate -lhwy -lpthread" \
    -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
