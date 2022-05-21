#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
make -f conda.makefile MKLROOT=${PREFIX}
mv PCAone ${PREFIX}/bin/
