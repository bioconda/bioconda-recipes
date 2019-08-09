#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cd src
make 
make PREFIX=${PREFIX} install
