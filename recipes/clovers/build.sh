#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
    OPENMP_FLAGS="-Xpreprocessor -fopenmp"
    OPENMP_LIBS="-lomp"
else
    OPENMP_FLAGS="-fopenmp"
    OPENMP_LIBS=""
fi

mkdir -p build
make clovers -j"${CPU_COUNT}" \
     CXX="${CXX}" \
     CXXFLAGS="-std=c++17 -DZLIB ${OPENMP_FLAGS} ${CXXFLAGS}" \
     LDFLAGS="${LDFLAGS} -lz ${OPENMP_LIBS}"

install -d "${PREFIX}/bin"
install -m 0755 clovers "${PREFIX}/bin/clovers"
