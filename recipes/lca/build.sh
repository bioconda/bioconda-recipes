#!/bin/bash

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

sed -i -e 's/-static //' Makefile
make
mkdir -p "${PREFIX}/bin"
mv LCA "${PREFIX}/bin/"
