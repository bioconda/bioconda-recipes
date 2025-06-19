#!/bin/bash

set -e
set -x

if [ "$(uname)" = "Darwin" ]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
else
  export LDFLAGS="-L$PREFIX/lib"
  export MKL_THREADING_LAYER="GNU"
fi
# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include

mkdir -p build

if [[ ${target_platform} == "linux-aarch64" ]]; then
# Conda does not yet support the MKL library for aarch64
  sed -i '/set(MKLROOT/s/^/#/' CMakeLists.txt
  sed -i '/include <optional>/a #\ \ \ \ include\ <cstdint>' external_libs/cxxopts/include/cxxopts.hpp
fi

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE="Release" \
  -S "${SRC_DIR}" \
  -B build

cmake --build build --target install -j "${CPU_COUNT}"

#make  -C build -j1 regenie
#make  -C build install
