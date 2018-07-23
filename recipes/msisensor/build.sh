#!/bin/bash

export CPATH=${PREFIX}/include

# curl -L https://github.com/samtools/samtools/archive/0.1.19.tar.gz > 0.1.19.tar.gz

# tar -xzf 0.1.19.tar.gz
# cd samtools-0.1.19
# make

export SAMTOOLS_ROOT=/opt/conda/pkgs/samtools-0.1.19-3
export HTSLIB_ROOT=/opt/conda/pkgs/htslib-1.6-0

echo "*** DEBUG ***"
find $SAMTOOLS_ROOT

echo "*** DEBUG ***"
find $HTSLIB_ROOT


# cd ..
make

mkdir -p $PREFIX/bin
cp msisensor $PREFIX/bin
