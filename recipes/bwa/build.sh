#!/bin/bash

sed -i.bak 's/^INCLUDES=$//g' Makefile

export CPPFLAGS="-I$PREFIX/include"
export INCLUDES="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make

mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin
