#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

./configure --prefix=$PREFIX
make LIBS+=-lhts
make install
