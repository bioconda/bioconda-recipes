#!/bin/sh

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export CFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

ls

ls gemBSsrc

./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make all
make install
