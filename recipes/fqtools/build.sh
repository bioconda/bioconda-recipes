#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

sed -i.bak 's/(gzFile\*)/(gzFile)/g' src/fqfile.c
sed -i.bak 's/gzFile\*/gzFile/g' src/fqfile.c

make CC="$CC -fcommon" CFLAGS="${CFLAGS} -O3 -I$PREFIX/include" LIBS="-L$PREFIX/lib -lhts -lz -lm" -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin
install -v -m 0755 bin/fqtools "$PREFIX/bin"
