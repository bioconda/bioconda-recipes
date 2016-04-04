#!/bin/bash
export CFLAGS=-I$PREFIX/include make

if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin
fi

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fasta $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
