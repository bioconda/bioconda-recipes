#!/bin/bash
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAG:qS -L$PREFIX/lib"
mkdir -p $PREFIX/bin
make 
cp minimap2 $PREFIX/bin