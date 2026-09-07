#!/usr/bin/env bash
set -euo pipefail

# macOS x86_64 builds target an older deployment baseline, while libc++ marks
# std::filesystem as available only on newer macOS. This conda-forge workaround
# disables those compile-time availability annotations without changing gfaidx.
if [[ "${target_platform}" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release
cmake --build build --verbose --parallel ${CPU_COUNT}
cmake --install build --prefix "${PREFIX}"
