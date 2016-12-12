#!/bin/sh

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS plugins install
