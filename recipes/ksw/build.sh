#!/bin/bash

# These are not used ksw's makefile
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
make clean
make PKG_VERSION=${PKG_VERSION} 
make PREFIX=${PREFIX}/bin PKG_VERSION=${PKG_VERSION} install
