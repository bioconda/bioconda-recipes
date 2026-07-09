#!/bin/bash
set -euo pipefail

# Build the NIS C++/LibTorch/OpenCV/CUDA executable against the conda environment.
# find_package(Torch)/find_package(OpenCV) resolve from $PREFIX via CMAKE_PREFIX_PATH.
cd cpp
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CUDA_COMPILER="${CUDA_HOME:-${PREFIX}}/bin/nvcc"
cmake --build . -j "${CPU_COUNT:-2}"

# Upstream names the binary `main`; install under an unambiguous name so it can
# live on the global PATH.
install -d "${PREFIX}/bin"
install -m 0755 main "${PREFIX}/bin/cellpheno-nis"
