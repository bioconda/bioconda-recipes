#!/bin/bash
set -ex

# Build DipGenie (override -march=native for portability)
make CXX="${CXX} -O3 -std=c++17" \
     CXXFLAGS="-fopenmp -pthread -O3 -lm -lz -lpthread -ldl -I${PREFIX}/include -L${PREFIX}/lib" \
     -j${CPU_COUNT}

# Install binary
mkdir -p "${PREFIX}/bin"
install -m 755 DipGenie "${PREFIX}/bin/DipGenie"
