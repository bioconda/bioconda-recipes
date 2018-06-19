#!/bin/bash
set -eu -o pipefail

export CPPFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

make
mkdir -p $PREFIX/bin
cp fastp $PREFIX/bin
