#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|/usr/local/bin|$(PREFIX)/bin|' Makefile
rm -rf *.bak

make CC="${CC}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install
