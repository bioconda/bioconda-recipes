#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make 
mv fermi  $PREFIX/bin
mv run-fermi.pl $PREFIX/bin
