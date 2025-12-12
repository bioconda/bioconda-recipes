#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

sed -i.bak 's|find_package(libmcfp REQUIRED)|find_package(mcfp REQUIRED)|' CMakeLists.txt
sed -i.bak 's|libmcfp::libmcfp|mcfp::mcfp|g' CMakeLists.txt

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
  -Dcifpp_DIR="${PREFIX}/lib/cmake/cifpp"

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
