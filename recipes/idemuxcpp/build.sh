#!/bin/sh

./configure --enable-tests --prefix="${PREFIX}" BAMTOOLS_CFLAGS="-I${PREFIX}/include/" BAMTOOLS_LIBS="-L${PREFIX}/lib/ -lbamtools"
make
make install
make check
