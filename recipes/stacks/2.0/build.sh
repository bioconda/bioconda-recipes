#!/bin/bash

# Using --libdir doesn't work.
export LDFLAGS="-L${CONDA_PREFIX}/lib" # for both stacks and included htslib dependency
export CPATH=${CONDA_PREFIX}/include         # for included htslib dependency

./configure --prefix=$PREFIX --enable-bam

# Force included htslib library to use conda compiler toolsuite
sed -i "s|^CC *.*|CC = $CC|" htslib/Makefile
sed -i "s|^AR *.*|AR = $AR|" htslib/Makefile
sed -i "s|^RANLIB *.*|RANLIB = $RANLIB|" htslib/Makefile

make
make install
