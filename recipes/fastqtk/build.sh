#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make clean

sed -i.bak 's|-march=native||' Makefile
rm -f *.bak

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 fastqtk "${PREFIX}/bin"
