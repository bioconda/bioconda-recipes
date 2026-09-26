#!/bin/bash
set -euo pipefail

# Point CMake's find_package(LibLZMA) explicitly at the conda host
# environment, rather than relying on system-default search paths that
# won't exist in bioconda's minimal build containers -- SPRING's own real,
# merged recipe needed a similar fix (a missing standard-library include
# under bioconda's stricter compiler settings), so this class of "worked
# locally, not in their environment" gap is real, not hypothetical.
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX"

cmake --build build -j"${CPU_COUNT:-2}"

mkdir -p "$PREFIX/bin"
cp build/best106 "$PREFIX/bin/best106"
cp build/capsule_decode "$PREFIX/bin/capsule_decode"
