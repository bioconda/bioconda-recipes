#!/bin/bash
#export C_INCLUDE_PATH=$PREFIX/include
#export CPLUS_INCLUDE_PATH=$PREFIX/include
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#export CPATH=${PREFIX}/include

set -e
./bin/abricate --setupdb

mkdir -p $PREFIX/bin
cp -r * $PREFIX
