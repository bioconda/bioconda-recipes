#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-O2|-O3|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-std=c99|-std=c11|' Makefile
rm -f *.bak

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 flash2 "$PREFIX/bin"
