#!/bin/sh

export CFLAGS="$CFLAGS"
export LDFLAGS+="-L{$PREFIX}/lib $LDFLAGS -lgsl"

autoreconf -i

./configure --enable-libgsl

make 
make install

