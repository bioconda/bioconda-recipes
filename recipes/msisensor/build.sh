#!/bin/bash

export CPATH=${PREFIX}/include

# curl -L https://github.com/samtools/samtools/archive/0.1.19.tar.gz > 0.1.19.tar.gz

# tar -xzf 0.1.19.tar.gz
# cd samtools-0.1.19
# make

LD_DEBUG=all make

export SAMTOOLS_ROOT=/opt/conda/pkgs/samtools-0.1.19-3/include/bam
export HTSLIB_ROOT=/opt/conda/pkgs/htslib-1.6-0

# cd ..
make

mkdir -p $PREFIX/bin
cp msisensor $PREFIX/bin
