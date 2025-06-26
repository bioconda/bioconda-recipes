#!/bin/bash
set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

if [[ "$(uname -m)" == "arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
elif [[ "$(uname -m)" == "aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

sed -i.bak s|find_package(Python 3.12.4|find_package(Python 3| CMakeLists.txt
rm -rf *.bak

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
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
  -DPYTHON_SITE_PACKAGES="${SP_DIR}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"

ninja -C build coot_headless_api -j"${CPU_COUNT}"
#cmake --build build --target coot_headless_api -j"${CPU_COUNT}"
ninja -C build install -j"${CPU_COUNT}"
#cmake --install build -j"${CPU_COUNT}"
