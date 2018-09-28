#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

./bootstrap.sh
./configure --prefix=$PREFIX --with-gsl=$PREFIX 
make
make install 
