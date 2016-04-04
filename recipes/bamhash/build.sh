#!/bin/bash
export CFLAGS=-I$PREFIX/include make all
export CXXFLAGS="${CFLAGS}"

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
