#!/bin/bash

mkdir -p $PREFIX/bin

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make
cp wtdbg2 wtdbg-cns wtpoa-cns $PREFIX/bin
