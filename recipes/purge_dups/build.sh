#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="$CFLAGS -I$PREFIX/include -g -Wall"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lz -lm"

# Compile purge_dups
cd src
make
cd ..

# Copy scripts
cp scripts/* ${PREFIX}/bin
