#!/usr/bin/env bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

echo $CFLAGS
ls $PREFIX/include
echo $LDFLAGS
ls $PREFIX/lib
echo $CPATH

${CC} ${CFLAGS} ${LDFLAGS} -lz -o readfq kseq_fastq_base.c
cp readfq $PREFIX/bin/readfq
