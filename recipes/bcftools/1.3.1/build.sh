#!/bin/sh

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make plugins
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS install
