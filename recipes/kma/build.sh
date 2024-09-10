#!/bin/bash

BINARIES="kma kma_index kma_shm kma_update"
make CFLAGS="${CFLAGS} -w -O3 -I${PREFIX}/include -L${PREFIX}/lib" -j "${CPU_COUNT}"

mkdir -p ${PREFIX}/bin
cp -rf $BINARIES $PREFIX/bin
mkdir -p $PREFIX/doc/kma
cp -rf README.md $PREFIX/doc/kma/
