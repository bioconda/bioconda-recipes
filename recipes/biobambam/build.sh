#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
LIBRARY_PATH=$PREFIX/lib
./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}/bin/biobambam2
make install
