#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# The upstream Makefile hardcodes CFLAGS=-O3, which drops the conda CFLAGS
# (including the -I$PREFIX/include needed for zlib.h), so pass them explicitly.
make CC="${CC}" CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib" -j"${CPU_COUNT}"

install -v -m 0755 syncon cutoff.py "${PREFIX}/bin"
