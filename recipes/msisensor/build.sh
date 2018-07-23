#!/bin/bash

export CPATH=${PREFIX}/include

# curl -L https://github.com/samtools/samtools/archive/0.1.19.tar.gz > 0.1.19.tar.gz

# tar -xzf 0.1.19.tar.gz
# cd samtools-0.1.19
# make

# DEBUGGING Where is samtools located?
echo "**** SAMTOOLS ****"
find / -name "*samtools*"

# export SAMTOOLS_ROOT=$PWD

# cd ..
make

mkdir -p $PREFIX/bin
cp msisensor $PREFIX/bin
