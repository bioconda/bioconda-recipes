#!/bin/sh

export CFLAGS="$CFLAGS"
export LDFLAGS="$LDFLAGS -lgsl"

autoreconf -i

./configure 

make 
make install

