#!/bin/bash
set -eu -o pipefail

make LDFLAGS="$LDFLAGS" DIR_INC=$PREFIX/include CC=$CXX
make install BINDIR=$PREFIX/bin
