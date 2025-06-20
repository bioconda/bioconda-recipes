#!/bin/bash

set -exo pipefail

cmake -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_CXX_STANDARD=17 \
  -DPython_EXECUTABLE="${PYTHON}" \
  -Dnanobind_DIR="${SP_DIR}/nanobind/cmake" \
  -DBOOST_ROOT="${PREFIX}" \
  -DEIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3" \
  -DGSL_ROOT_DIR="${PREFIX}" \
  -DRDKIT_ROOT="${PREFIX}"

cmake --build build --target coot_headless_api --parallel ${CPU_COUNT}
cmake --install build
