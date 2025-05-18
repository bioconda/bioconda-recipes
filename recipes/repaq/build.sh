#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="$LDFLAGS -L${PREFIX}/lib -lc"
fi

make DIR_INC="${PREFIX}/include" LIBRARY_DIRS="${PREFIX}/lib" CXX="${CXX}" -j"${CPU_COUNT}"
make install BINDIR="${PREFIX}/bin"
