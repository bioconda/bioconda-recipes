#!/bin/bash

# These are not used ksw's makefile
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
make clean
make PKG_VERSION=${GIT_DESCRIBE_TAG} 
make PREFIX=${PREFIX}/bin PKG_VERSION=${GIT_DESCRIBE_TAG} install
