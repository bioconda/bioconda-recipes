#!/usr/bin/env bash

set -exo pipefail

# Prevent build failures due to insufficient memory in the CI environment
# Use parallel build because of serial build on osx-arm64 causing occasional errors
if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=$(( CPU_COUNT * 70 / 100))
  if [ "$CPU_COUNT" -gt 8 ]; then
    CPU_COUNT=8
  fi
  export CPU_COUNT
  echo "CPU_COUNT for build = $CPU_COUNT"
fi
if [[ $(uname -m) == "x86_64" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=1"
else
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=0"
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -framework OpenGL"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DOST_ROOT="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DOPTIMIZE=ON \
    -DDISABLE_DOCUMENTATION=1

make -j"${CPU_COUNT}"

if [ "${CIRCLECI}" != "true" ]; then
    make check
fi

make install
cd "${SRC_DIR}" && rm -rf build
