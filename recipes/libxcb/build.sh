#!/bin/bash

export AM_PATH_PYTHON="$PREFIX/bin"
export pythondir="$PREFIX/bin"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
./autogen.sh LDFLAGS="-L$PREFIX/lib" CPPFLAGS="-I$PREFIX/include"
./configure --prefix=$PREFIX --enable-network
make
make install
unset ACLOCAL_FLAGS CFLAGS LDFLAGS

