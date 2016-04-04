#!/bin/bash
CFLAGS=-I$PREFIX/include

make

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fasta $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
