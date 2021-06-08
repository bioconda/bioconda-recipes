#!/bin/sh

export CFLAGS="$CFLAGS"
export LDFLAGS+="-L{$PREFIX}/lib $LDFLAGS -lgsl"
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

autoreconf -i

./configure --enable-libgsl --prefix=$PREFIX --with-gsl-prefix=$PREFIX

make 
make install

