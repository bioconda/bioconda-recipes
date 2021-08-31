#!/bin/bash
set -eu -o pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="$LDFLAGS -lc"
fi
make DIR_INC="$PREFIX/include" LIBRARY_DIRS="$PREFIX/lib" CXX=$CXX
mkdir -p $PREFIX/bin
make install BINDIR=$PREFIX/bin
