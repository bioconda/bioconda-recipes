#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make MKLROOT=${PREFIX}
mv PCAone ${PREFIX}/bin/
