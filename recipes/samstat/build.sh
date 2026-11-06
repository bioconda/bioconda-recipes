#!/usr/bin/env bash
set -euo pipefail

# CMAKE_ARGS (set by conda-build) carries the toolchain: compiler, sysroot / SDK, deployment
# target and, for osx-arm64, the cross-compilation settings. samstat passes these on to the
# bundled htslib; HOST becomes its configure --host, in a cross build only. The test suite is
# not built here (meta.yaml runs its own checks).
cmake -S . -B build ${CMAKE_ARGS:-} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DSAMSTAT_HTSLIB_HOST="${HOST:-}" \
        -DBUILD_TESTING=OFF
cmake --build build -j"${CPU_COUNT:-2}"
cmake --install build
