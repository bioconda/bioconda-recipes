#!/bin/bash
set -eu -o pipefail

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make
mkdir -p $PREFIX/bin
cp fastp $PREFIX/bin
