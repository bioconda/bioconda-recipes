#!/bin/bash
set -eu -o pipefail

cd external/htslib-*
make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
cd ../..
sed -i.bak 's^-Isrc/c/^-Isrc/c/ -I${PREFIX}/include^' Makefile
sed -i.bak 's^-lpthread^-lpthread -L$(PREFIX)/lib^' Makefile
make CC=$CC CXX=$CXX
mkdir -p $PREFIX/bin
cp bin/gvcfgenotyper $PREFIX/bin
