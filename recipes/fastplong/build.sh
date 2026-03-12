#!/bin/bash
set -xeu -o pipefail
mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make PREFIX="${PREFIX}" CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS} -O3 -std=c++14" \
  INCLUDE_DIRS="$PREFIX/include" \
  LIBRARY_DIRS="$PREFIX/lib" -j"${CPU_COUNT}"
make install
