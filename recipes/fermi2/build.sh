#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Wno-implicit-function-declaration -Wno-int-conversion"

make CC="$CC" CFLAGS="$CFLAGS" INCLUDES="-I$PREFIX/include" LIBS="-L${PREFIX}/lib -lm -lz -pthread" -j"${CPU_COUNT}"

install -v -m 0755 fermi2 fermi2.pl "$PREFIX/bin"
