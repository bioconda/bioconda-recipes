#!/bin/bash
set -euo pipefail

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_SYSTEM_HTSLIB=ON \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -L${PREFIX}/lib"

make -j"${CPU_COUNT}"

# Install binary
install -d "${PREFIX}/bin"
install -m 755 bin/basevar "${PREFIX}/bin/"
