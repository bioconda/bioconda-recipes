#!/bin/bash

set -xe

export CFLAGS="${CFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.15  # Required to use std::filesystem
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -D_LIBCPP_DISABLE_AVAILABILITY"
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi  

cmake -H. -B"${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0 \
  -DUSE_HTSLIB=1 -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  "${CONFIG_ARGS}"
cmake --build "${PREFIX}" -j "${CPU_COUNT}" -v
