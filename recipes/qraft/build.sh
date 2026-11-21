#!/bin/bash
set -euxo pipefail

# Dynamic build with conda's toolchain, no -march=native. jemalloc on Linux
# and the system allocator on macOS, as in the release binaries.
if [[ "${target_platform}" == linux-* ]]; then
  jemalloc=ON
else
  jemalloc=OFF
fi

cmake -S . -B build ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DQRAFT_BUILD_TESTS=OFF \
  -DQRAFT_STATIC_EXECUTABLE=OFF \
  -DQRAFT_NATIVE_OPTIMIZATIONS=OFF \
  -DQRAFT_USE_JEMALLOC=${jemalloc}

cmake --build build --target qraft --parallel "${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -m 0755 build/qraft "${PREFIX}/bin/"
