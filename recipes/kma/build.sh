#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
mkdir -p $PREFIX/doc/kma

BINARIES="kma kma_index kma_shm kma_update"
make CFLAGS="${CFLAGS} -w -O3 -I${PREFIX}/include -L${PREFIX}/lib" -j"${CPU_COUNT}"

install -v -m 0755 $BINARIES "$PREFIX/bin"

cp -rf README.md $PREFIX/doc/kma/
