#!/bin/bash
export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
