#!/bin/bash
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
mkdir -p $PREFIX/bin
make $CFLAGS $LDFLAGS
cp minimap2 $PREFIX/bin
