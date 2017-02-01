#!/bin/bash

ln -s $PREFIX/lib $PREFIX/lib64

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"

# export CFLAGS="-I$PREFIX/include -I$PREFIX/include/glib-2.0 -I$PREFIX/include/glib-2.0/gobject -I$PREFIX/include/glib-2.0/glib -I$PREFIX/include/glib-2.0/gio -I$PREFIX/include/gobject-introspection-1.0 -I$PREFIX/lib/glib-2.0/include -I/usr/include -I/usr/include/X11 -I/usr/include/X11/extensions"
# export LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib64"

# export LD_RUN_PATH="$PREFIX/lib64:$PREFIX/lib64:$LD_RUN_PATH"

# export LIBFFI_CFLAGS="-I$PREFIX/include"
# export LIBFFI_LIBS="-L$PREFIX/lib"

./configure  --prefix=$PREFIX --enable-introspection=yes CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" 

sed -i.bak 's|#!/usr/bin/perl.*|#!/usr/bin/env perl|' ./gdk-pixbuf/*.pl

make
make install
