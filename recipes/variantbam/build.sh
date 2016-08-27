#!/bin/bash
set -eu -o pipefail

export CPPFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
export LIBS=-lpthread

./configure --prefix=$PREFIX
make
mkdir -p $PREFIX/bin
cp src/variant $PREFIX/bin
