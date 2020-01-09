#!/bin/bash
set -eu -o pipefail

make DIR_INC="$PREFIX/include" LDFLAGS="$LDFLAGS" CC=$CXX
mkdir -p $PREFIX/bin
mv genefuse $PREFIX/bin
