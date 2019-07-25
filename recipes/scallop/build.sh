#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LIBS="$LIBS -lhts -lboost"

./configure --prefix=$PREFIX
make
make install
