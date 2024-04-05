#!/bin/bash
set -xeuo pipefail
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make CC="$CC -fcommon" CXX="$CXX -fcommon" LDFLAGS="$LDFLAGS"
mkdir -p $PREFIX/bin
cp ema $PREFIX/bin
