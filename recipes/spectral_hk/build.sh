#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -Wall -O3"

sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|$(AR) -r|$(AR) -rcs|' Makefile
rm -rf *.bak

make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 spectral_hk "$PREFIX/bin"
