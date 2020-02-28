#!/bin/sh

#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib -lhdf5"

autoreconf -i

./configure 

make 
make install

