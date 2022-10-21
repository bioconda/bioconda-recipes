#!/bin/bash

set -eu -o pipefail

mkdir -p build
cd build

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake ..  --trace-expand
make CXX="$CXX" CC="$CC" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"

mv install/bin/ExpansionHunter ${PREFIX}/bin/ExpansionHunter