#!/bin/bash
set -xe

make -j${CPU_COUNT} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -fopenmp -std=c++14" \
    EIGEN_INC="${PREFIX}/include/eigen3" \
    SPECTRA_INC="${PREFIX}/include" \
    BOOST_INC="${PREFIX}/include"

install -d "${PREFIX}/bin"
install -m 755 flashpca "${PREFIX}/bin/flashpca"
