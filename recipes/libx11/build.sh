#!/bin/bash

export XORG_PREFIX="$PREFIX"
export PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PREFIX/lib/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"
export CFLAGS="-I$PREFIX/include"
export X11_CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export X11_LIBS="-L$PREFIX/lib"
./autogen.sh
./configure --prefix=$PREFIX --enable-network
make
make install
