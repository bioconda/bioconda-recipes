#!/bin/bash

ln -s $PREFIX/lib $PREFIX/lib64

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"

if  [[ "$OSTYPE" == "darwin"* ]]; then
  ./configure  --prefix=$PREFIX --enable-introspection=yes CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib" 
else
  ./configure  --prefix=$PREFIX --enable-introspection=yes CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
fi

sed -i.bak 's|#!/usr/bin/perl.*|#!/usr/bin/env perl|' ./gdk-pixbuf/*.pl

make
make install
