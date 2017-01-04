#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd src
ls
make -f Makefile
cp baseml basemlg codeml pamp evolver yn00 chi2 $PREFIX/bin

