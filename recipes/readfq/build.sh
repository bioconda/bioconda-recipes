#!/usr/bin/env bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

echo $CFLAGS
echo $LDFLAGS
echo $CPATH

${CC} -lz -o readfq kseq_fastq_base.c
cp readfq $PREFIX/bin/readfq
