#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBS="-lboost -lhts"

./configure --prefix=$PREFIX
make
make install
