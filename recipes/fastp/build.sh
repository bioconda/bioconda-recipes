#!/bin/bash
set -eu -o pipefail

export CFLAGS=-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

# XXX print the linker search paths
ldconfig -v 2>/dev/null | grep -v ^$'\t'

make
mkdir -p $PREFIX/bin
cp fastp $PREFIX/bin
