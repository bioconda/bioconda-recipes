#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -L$PREFIX/lib"

make -j"${CPU_COUNT}" CC="${CC}" CFLAGS="${CFLAGS}"

chmod 0755 yahs agp_to_fasta juicer
mv yahs ${PREFIX}/bin
mv agp_to_fasta ${PREFIX}/bin
mv juicer ${PREFIX}/bin
