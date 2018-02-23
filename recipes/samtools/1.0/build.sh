#!/bin/sh
set -e

# remove hard-coded *flags
sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile
sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX
