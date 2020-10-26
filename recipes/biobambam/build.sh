#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
LDFLAGS="-L$PREFIX/lib"
./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}/bin/biobambam2
make install
