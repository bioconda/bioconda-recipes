#!/bin/bash
set -eu -o pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="$LDFLAGS -lc"
fi
make LDFLAGS="$LDFLAGS" DIR_INC=$PREFIX/include CC=$CXX
mkdir -p $PREFIX/bin
make install BINDIR=$PREFIX/bin
