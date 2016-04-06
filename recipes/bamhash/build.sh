#!/bin/bash
export DYLD_LIBRARY_PATH=$PREFIX/lib
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
export CFLAGS=-03-fPIC-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include

make all

mv bamhash_checksum_bam $PREFIX/bin
mv bamhash_checksum_fastq $PREFIX/bin
