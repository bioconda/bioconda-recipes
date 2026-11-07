#!/bin/bash
set -euxo pipefail

# GPU code for Volta to Hopper (sm_70-sm_90) plus PTX for newer GPUs. Set explicitly: conda's nvcc exports CUDAARCHS
# (sm_50 to sm_121), which would otherwise be used (nvcc gets -ccbin=$CXX from its own activation script).
cmake -S . -B build ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="70-real;75-real;80-real;86-real;89-real;90-real;90-virtual"
cmake --build build -j "${CPU_COUNT}"

# CMakeLists.txt has no install rule
install -d "${PREFIX}/bin"
install -m 0755 build/galn "${PREFIX}/bin/galn"
