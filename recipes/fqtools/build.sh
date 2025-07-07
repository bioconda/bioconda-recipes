#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's/(gzFile\*)/(gzFile)/g' src/fqfile.c
sed -i.bak 's/gzFile\*/gzFile/g' src/fqfile.c

make CC="$CC -fcommon" CFLAGS="-I$PREFIX/include" LIBS="-L$PREFIX/lib -lhts -lz -lm"
mkdir -p $PREFIX/bin
cp bin/fqtools $PREFIX/bin
