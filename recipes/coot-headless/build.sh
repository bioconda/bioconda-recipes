#!/bin/bash

set -exo pipefail

sed -i.bak s|find_package(Python 3.12.4|find_package(Python 3| CMakeLists.txt

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_CXX_STANDARD=17 \
  -DPython_EXECUTABLE="${PYTHON}" \
  -Dnanobind_DIR="${SP_DIR}/nanobind/cmake" \
  -DBOOST_ROOT="${PREFIX}" \
  -DEIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3" \
  -DGSL_ROOT_DIR="${PREFIX}" \
  -DRDKIT_ROOT="${PREFIX}" \
  -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
  -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw.so" \
  -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw.so" \
  -DPYTHON_SITE_PACKAGES="${SP_DIR}"

cmake --build build --target coot_headless_api
cmake --install build
