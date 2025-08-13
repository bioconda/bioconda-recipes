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

mkdir -p "${PREFIX}/share/alphafill"
mkdir -p "${PREFIX}/share/libcifpp"

sed -i.bak 's|${CIFPP_SHARE_DIR}|$ENV{PREFIX}/share/libcifpp|g' CMakeLists.txt
sed -i.bak 's|DESTINATION ${ALPHAFILL_DATA_DIR}|DESTINATION $ENV{PREFIX}/share/alphafill|g' CMakeLists.txt

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_SYSCONFDIR="${PREFIX}/etc" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DZLIB_ROOT="${PREFIX}" \
  -DBUILD_WEB_APPLICATION=OFF \
  -DBUILD_DOCUMENTATION=OFF \
  -DALPHAFILL_DATA_DIR="" \
  -DBUILD_TESTING=ON

cmake --build build --parallel "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build
