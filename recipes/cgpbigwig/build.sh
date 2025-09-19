#!/bin/bash
set -xe

# This is needed for the testing in the makefile to work
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

sed -i.bak "s#gcc#${CC}#" c/Makefile
rm -f c/*.bak

make -j"${CPU_COUNT}" -C c prefix="$PREFIX" HTSLOC="$PREFIX/lib" OPTINC="-I$PREFIX/include" LFLAGS="${LDFLAGS}"

install -v -m 0755 bin/* "$PREFIX/bin"
