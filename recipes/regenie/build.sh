#!/bin/bash
set -ex

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPATH="${PREFIX}/include"

if [[ "$(uname -s)" == "Darwin" ]]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -Wl,-pie -Wl,-headerpad_max_install_names"
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
  export MKL_THREADING_LAYER="GNU"
  export CONFIG_ARGS=""
fi

if [[ ${target_platform} == "linux-aarch64" ]]; then
# Conda does not yet support the MKL library for aarch64
  sed -i.bak '/set(MKLROOT/s/^/#/' CMakeLists.txt
  sed -i.bak '/include <optional>/a #\ \ \ \ include\ <cstdint>' external_libs/cxxopts/include/cxxopts.hpp
fi

cmake -S "${SRC_DIR}" -B build -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"
  
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
