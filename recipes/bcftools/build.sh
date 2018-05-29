#!/bin/sh

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="$CPPFLAGS" LDFLAGS="-L$PREFIX/lib"
make all CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS
make install
