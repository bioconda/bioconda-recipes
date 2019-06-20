#!/bin/bash

set -euo pipefail

# These are used ksw's makefile
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-g -Wall -Wno-unused-function -O2 -I${PREFIX}/include"
LDFLAGS="-Lsrc/parasail/build -L${PREFIX}/lib"

mkdir -p $PREFIX/bin
make CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" PREFIX="${PREFIX}/bin" PKG_VERSION="${PKG_VERSION}" -j$CPU_COUNT clean all install
