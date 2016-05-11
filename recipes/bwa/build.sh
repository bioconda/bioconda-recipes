#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make

mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin
