#!/bin/bash
set -euxo pipefail

sed -i.bak 's/-march=native/-mtune=generic/' Makefile

make -j"${CPU_COUNT}" \
    CXX="${CXX}" \
    EIGEN_INC="${PREFIX}/include/eigen3" \
    SPECTRA_INC="${SRC_DIR}/spectra-0.8.1/include" \
    BOOST_INC="${PREFIX}/include" \
    BOOST_LIB="${PREFIX}/lib"

install -d "${PREFIX}/bin"
install -m 755 flashpca "${PREFIX}/bin/flashpca"
