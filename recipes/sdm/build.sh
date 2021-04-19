#!/bin/bash

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# Workaround for sdm 1.73, fixed in https://github.com/hildebra/sdm/pull/3
rm -f *.o

sed -i -e 's/-static //' Makefile
make
mkdir -p "${PREFIX}/bin"
mv sdm "${PREFIX}/bin/"
