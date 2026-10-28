#!/bin/bash
set -euo pipefail

command -v nvcc >/dev/null 2>&1 || { echo "ERROR: nvcc not found in build env"; exit 1; }

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p build_cuda
cd build_cuda

cmake .. ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DTBB_DIR="${PREFIX}" \
  -DUSE_CUDA=ON -DUSE_HIP=OFF -DUSE_CPU=OFF \
  -DCMAKE_CUDA_COMPILER="$(command -v nvcc)"

cmake --build . --target install --parallel ${CPU_COUNT}
cmake --install .
