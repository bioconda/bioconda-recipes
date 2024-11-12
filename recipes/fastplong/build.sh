#!/bin/bash
set -xeu -o pipefail
mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} INCLUDE_DIRS="$PREFIX/include" LIBRARY_DIRS="$PREFIX/lib"
make install
