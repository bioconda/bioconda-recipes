#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o "${PREFIX}/bin/readfq" kseq_fastq_base.c -lz
