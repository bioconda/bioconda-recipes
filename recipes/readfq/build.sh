#!/usr/bin/env bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

${CC} ${CFLAGS} ${LDFLAGS} -lz -o readfq kseq_fastq_base.c
cp readfq $PREFIX/bin/readfq
