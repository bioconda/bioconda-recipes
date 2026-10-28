#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

make CC="${CC} -O3" -j"${CPU_COUNT}"

install -v -m 0755 mreps "$PREFIX/bin"
