#!/bin/bash

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

sed -i.bak -e 's/ -static//' Makefile
make
mkdir -p "${PREFIX}/bin"
mv sdm "${PREFIX}/bin/"
