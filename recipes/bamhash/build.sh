#!/bin/bash
CXXFLAGS=-I$PREFIX/include make all

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
