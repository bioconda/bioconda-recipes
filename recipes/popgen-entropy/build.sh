#!/bin/sh

#export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -lgsl"

autoreconf -i

./configure 

make 
make install

