#!/bin/bash
set -eu -o pipefail

make DIR_INC="$PREFIX/include" LDFLAGS="$LDFLAGS" CC=$CXX
make install BINDIR=$PREFIX/bin
