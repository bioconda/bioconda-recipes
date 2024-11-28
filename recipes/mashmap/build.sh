#!/bin/bash

set -xe

export CFLAGS="${CFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=10.15 -D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION=1"
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
elif 
  export CONFIG_ARGS=""
fi  

cmake -H. -B"${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0 \
  -DUSE_HTSLIB=1 -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  "${CONFIG_ARGS}"
cmake --build "${PREFIX}" -j "${CPU_COUNT}" -v
