#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
LDFLAGS="-L$PREFIX/lib"

#autoreconf -i -f
./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}/bin/
make install
