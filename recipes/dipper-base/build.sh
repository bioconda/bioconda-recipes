#!/bin/bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p build_cpu
cd build_cpu

cmake .. ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DTBB_DIR="${PREFIX}" \
  -DUSE_CUDA=OFF -DUSE_HIP=OFF -DUSE_CPU=ON

cmake --build . --target install --parallel ${CPU_COUNT}
cmake --install .
