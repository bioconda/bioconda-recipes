#!/bin/bash
export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAG:qS -L$PREFIX/lib"
mkdir -p $PREFIX/bin
make $CFLAGS $LDFLAGS
cp minimap2 $PREFIX/bin