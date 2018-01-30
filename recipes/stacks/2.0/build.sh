#!/bin/bash

# Using --libdir doesn't work.
export LDFLAGS="-L${CONDA_PREFIX}/lib"

./configure --prefix=$PREFIX --enable-sparsehash --enable-bam --includedir=${CONDA_PREFIX}/include/bam
make
make install
