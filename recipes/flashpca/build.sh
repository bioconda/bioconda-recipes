#!/bin/bash
set -euxo pipefail

make -j"${CPU_COUNT}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -fopenmp -std=c++14 -I${PREFIX}/include/eigen3 -I${PREFIX}/include" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
    EIGEN_INC="${PREFIX}/include/eigen3" \
    SPECTRA_INC="${PREFIX}/include" \
    BOOST_INC="${PREFIX}/include"

install -d "${PREFIX}/bin"
install -m 755 flashpca "${PREFIX}/bin/flashpca"
