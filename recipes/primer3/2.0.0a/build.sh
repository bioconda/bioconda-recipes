#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
make -C src -f Makefile

binaries="\
long_seq_tm_test \
ntdpal \
oligotm \
primer3_core \
"

for i in $binaries; do cp src/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
