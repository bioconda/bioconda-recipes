#!/bin/sh

#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib -lhdf5"

autoreconf -i

./configure --prefix=$HOME/entropy

make 
make install

