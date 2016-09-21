#!/bin/bash

export CPATH=${PREFIX}/include

./configure --prefix=$PREFIX --enable-sparsehash --enable-bam --includedir=${PREFIX}/include/bam --libdir=${PREFIX}/lib
make
make install
