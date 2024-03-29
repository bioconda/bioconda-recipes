#!/bin/bash
set -eu -o pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="$LDFLAGS -lc"
fi
export LD_LIBRARY_PATH=$PREFIX/lib
make DIR_INC="$PREFIX/include" LDFLAGS="$LDFLAGS" CC=$CXX
mkdir -p $PREFIX/bin
mv genefuse $PREFIX/bin
