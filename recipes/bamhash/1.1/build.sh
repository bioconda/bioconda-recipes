#!/bin/bash
export LDFLAGS=-L$PREFIX/lib
export CXXFLAGS=-I$PREFIX/include

make all

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
mv bamhash_checksum_fasta $PREFIX/bin
