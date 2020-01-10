#!/bin/bash
set -eu -o pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="$LDFLAGS -lc"
fi
make DIR_INC="$PREFIX/include" LDFLAGS="$LDFLAGS" CXX=$CXX
mkdir -p $PREFIX/bin
make install BINDIR=$PREFIX/bin
