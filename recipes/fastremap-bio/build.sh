#!/bin/bash
mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make CXX=$CXX EXEC="$PREFIX/bin/FastRemap" INC="$PREFIX/include" LIB="$PREFIX/lib"
