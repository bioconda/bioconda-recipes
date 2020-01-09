#!/bin/bash
set -eu -o pipefail

make LDFLAGS="$LDFLAGS" DIR_INC=$PREFIX/include CC=$CXX
mkdir -p $PREFIX/bin
make install BINDIR=$PREFIX/bin
