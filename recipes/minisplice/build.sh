#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|-std=c99|-std=c11|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 minisplice "$PREFIX/bin"
