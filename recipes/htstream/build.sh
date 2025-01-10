#!/usr/bin/env bash
set -eu -o pipefail

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3" \
  -DCMAKE_LIBRARY_PATH="${PREFIX}/lib" \
  -DCMAKE_INCLUDE_PATH="${PREFIX}/include" \
  "${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}"
