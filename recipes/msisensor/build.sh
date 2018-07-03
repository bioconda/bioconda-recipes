#!/bin/bash

curl -L https://github.com/samtools/samtools/archive/0.1.19.tar.gz > 0.1.19.tar.gz
tar -xzf 0.1.19.tar.gz

#export SAMTOOLS_ROOT=samtools-0.1.19
export SAMTOOLS_ROOT=${PREFIX}/include/bam

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make
make install

mkdir -p $PREFIX/bin
cp msisensor $PREFIX/bin
