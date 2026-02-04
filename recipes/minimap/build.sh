#!/bin/bash

mkdir -p $PREFIX/bin

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make CC=$CC CFLAGS="$CFLAGS" LIBS="-L${PREFIX}/lib -lm -lz -lpthread" LDFLAGS="$LDFLAGS"
make extra CC=$CC CFLAGS="$CFLAGS $LDFLAGS" LIBS="-L${PREFIX}/lib -lm -lz -lpthread" LDFLAGS="$LDFLAGS"

cp minimap $PREFIX/bin 
cp minimap-lite $PREFIX/bin
cp sdust $PREFIX/bin
  
