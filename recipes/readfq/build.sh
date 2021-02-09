#!/usr/bin/env bash

mkdir -p "${PREFIX}/bin"
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o "${PREFIX}/bin/readfq" kseq_fastq_base.c -lz
