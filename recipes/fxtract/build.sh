#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p ${PREFIX}/bin

make -j4 all CC=${CC} CXX=${CXX}

chmod +x fxtract
cp fxtract ${PREFIX}/bin/
