#!/bin/bash

export CPATH=${PREFIX}/include

./configure --prefix=$PREFIX --enable-sparsehash --enable-bam --with-bam-include-path=${PREFIX}/include/bam --with-bam-lib-path=${PREFIX}/lib
make
make install
