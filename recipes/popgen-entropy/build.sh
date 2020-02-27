#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -lhdf5_cpp -lhdf5"
export CPATH=${PREFIX}/include

aclocal
autoheader
automake --add-missing --foreign
autoconf

./configure --prefix=$HOME/entropy

make 
make install

