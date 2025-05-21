#!/bin/bash
set -euo pipefail

# uses random_shuffle which was removed in C++17
export CXXFLAGS="-std=c++14 -O3 ${CXXFLAGS}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -if
./configure --prefix="${PREFIX}" --enable-pca \
  --disable-dependency-tracking --enable-silent-rules \
  --disable-option-checking CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install
