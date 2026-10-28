#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -w -O3 -I$PREFIX/include -L$PREFIX/lib"

mkdir -p "${PREFIX}/bin"
mkdir -p "$PREFIX/doc/ccphylo"

make CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 ccphylo "$PREFIX/bin"
cp -f README.md "$PREFIX/doc/ccphylo/"
