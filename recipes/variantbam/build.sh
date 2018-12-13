#!/bin/bash
set -eu -o pipefail

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LIBS=-lpthread

./configure --prefix=$PREFIX
make
mkdir -p $PREFIX/bin
cp src/variant $PREFIX/bin
