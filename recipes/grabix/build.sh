#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

set -eu -o pipefail

make
mkdir -p $PREFIX/bin
cp grabix $PREFIX/bin
