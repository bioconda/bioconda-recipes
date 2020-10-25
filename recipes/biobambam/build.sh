#!/bin/bash
set -eu

mkdir -p $PREFIX/bin

./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}/bin/biobambam2
make install
