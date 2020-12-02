#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX" --with-boost="$PREFIX"

make LIBS+=-lhts
make install
