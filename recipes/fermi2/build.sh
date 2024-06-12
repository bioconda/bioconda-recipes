#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} CC="$CC" CFLAGS="$CFLAGS" INCLUDES="-I$PREFIX/include" LIBS="-L${PREFIX}/lib -lm -lz -lpthread"

mv fermi2  $PREFIX/bin
mv fermi2.pl  $PREFIX/bin
