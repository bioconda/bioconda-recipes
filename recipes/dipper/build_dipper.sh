#!/bin/bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

BUILD_DIR="build_${PKG_NAME}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

EXTRA_FLAGS="-DCMAKE_BUILD_TYPE=Release -DTBB_DIR=${PREFIX}"

case "${PKG_NAME}" in
  dipper)
    cmake .. ${CMAKE_ARGS} ${EXTRA_FLAGS} -DUSE_CUDA=OFF -DUSE_HIP=OFF -DUSE_CPU=ON
    ;;
  dipper-cuda)
    command -v nvcc >/dev/null 2>&1 || { echo "ERROR: nvcc not found"; exit 1; }
    cmake .. ${CMAKE_ARGS} ${EXTRA_FLAGS} \
      -DUSE_CUDA=ON -DUSE_HIP=OFF -DUSE_CPU=OFF \
      -DCMAKE_CUDA_COMPILER="$(command -v nvcc)"
    ;;
  *)
    echo "ERROR: unknown PKG_NAME '${PKG_NAME}'"; exit 1
    ;;
esac

cmake --build . --target install --parallel ${CPU_COUNT}
cmake --install .
