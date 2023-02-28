#!/bin/bash

set -eu -o pipefail

mkdir -p build
cd build

export BOOST_ROOT=${PREFIX}
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake ..
make CXX="$CXX" CC="$CC" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"

mv ExpansionHunter ${PREFIX}/bin/ExpansionHunter
