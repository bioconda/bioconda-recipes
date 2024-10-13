#!/bin/bash

set -xe

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH=${PREFIX}/include

if [[ ${HOST} =~ .*darwin.* ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.15  # Required to use std::filesystem
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi  

cmake -H. -B${PREFIX} -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0 -DUSE_HTSLIB=1 -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
cmake --build ${PREFIX} -j ${CPU_COUNT}
