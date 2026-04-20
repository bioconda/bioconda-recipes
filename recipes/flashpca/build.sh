#!/bin/bash
set -xe

# Use C++14
export CXXFLAGS="${CXXFLAGS} -std=c++14"

# Download Spectra 0.6.0
SPECTRA_VERSION=0.6.0
wget --no-check-certificate https://github.com/yixuan/spectra/archive/v${SPECTRA_VERSION}.tar.gz -O spectra.tar.gz
tar xzf spectra.tar.gz
SPECTRA_DIR="spectra-${SPECTRA_VERSION}"

# Add include paths
export CXXFLAGS="${CXXFLAGS} -I${SPECTRA_DIR}/include -I${SPECTRA_DIR}/include/Spectra -I${PREFIX}/include/eigen3 -I${PREFIX}/include"

# Define VERSION macro
export CXXFLAGS="${CXXFLAGS} -DVERSION=\\\"2.0\\\""

# Link against Boost libraries and OpenBLAS
export LDFLAGS="${LDFLAGS} -lboost_program_options -lboost_random -lopenblas"

# Build
make -j${CPU_COUNT} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -fopenmp" \
    LDFLAGS="${LDFLAGS}"

# Install
install -d "${PREFIX}/bin"
install -m 755 flashpca "${PREFIX}/bin/flashpca"
if [ -f "randompca" ]; then
    install -m 755 randompca "${PREFIX}/bin/randompca"
fi
