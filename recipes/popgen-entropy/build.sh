#!/bin/sh

export CFLAGS="$CFLAGS"
export LDFLAGS+="-L{$PREFIX}/lib $LDFLAGS -lgsl"

autoreconf -i

./configure 

make 
make install

