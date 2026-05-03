#!/bin/bash
set -euo pipefail

# The upstream Makefile uses a plain `gcc` to compile C++ code and links
# libstdc++ explicitly. Override CC with the conda C++ compiler, and pass
# both compile and link flags so the build picks up conda's sysroot,
# headers, and libraries (including zlib in $PREFIX/lib).
make CC="${CXX}" \
     CFLAGS="-Wall -std=c++17 ${CXXFLAGS}" \
     LDFLAGS="${LDFLAGS} -lstdc++ -lz -lm"

# Install the binary into ${PREFIX}/bin
mkdir -p "${PREFIX}/bin"
cp restrander "${PREFIX}/bin/"

# Install runtime config JSON files
mkdir -p "${PREFIX}/share/restrander/config"
cp config/*.json "${PREFIX}/share/restrander/config/"
