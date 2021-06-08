#!/bin/bash
set -eu -o pipefail
mkdir -p $PREFIX/bin

make INCLUDE_DIRS="$PREFIX/include" LIBRARY_DIRS="$PREFIX/lib"
make install
