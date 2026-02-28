#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

sed -i.bak -e 's/ -static//' Makefile
sed -i.bak -e 's/-lpthread/-pthread/' Makefile
rm -f *.bak

make -j"${CPU_COUNT}"

install -v -m 755 sdm "${PREFIX}/bin"
