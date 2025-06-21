#!/bin/bash
set -ex

if [[ "$(uname -s)" == "Darwin" ]]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="${LDFLAGS} -Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
else
  export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
  export MKL_THREADING_LAYER="GNU"
fi
# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export CPATH="${PREFIX}/include"

mkdir -p build

if [[ ${target_platform} == "linux-aarch64" ]]; then
# Conda does not yet support the MKL library for aarch64
  sed -i.bak '/set(MKLROOT/s/^/#/' CMakeLists.txt
  sed -i.bak '/include <optional>/a #\ \ \ \ include\ <cstdint>' external_libs/cxxopts/include/cxxopts.hpp
fi

cmake -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
  -S "${SRC_DIR}" \
  -B build

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
