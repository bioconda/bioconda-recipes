#!/bin/bash

set -xe

export CFLAGS="${CFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION=1 -Wno-deprecated-builtins -Wno-vla-cxx-extension"
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi  

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0 \
  -DUSE_HTSLIB=1 -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}" -v
