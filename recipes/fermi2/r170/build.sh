#!/bin/bash

mkdir -p $PREFIX/bin

make CC="$CC" CFLAGS="$CFLAGS" INCLUDES="-I$PREFIX/include" LIBS="-L${PREFIX}/lib -lm -lz -lpthread"

mv fermi2  $PREFIX/bin
mv fermi2.pl  $PREFIX/bin
