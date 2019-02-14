#!/bin/bash

export LDFLAGS="$LDFLAGS -Wl,-rpath -Wl,$PREFIX/lib"
export MAKEFLAGS="-j$CPU_COUNT"

./configure \
    --prefix=$PREFIX \
    --disable-docs \
    --with-arbhome=$PREFIX/lib/arb \
    --with-boost=$PREFIX \
    --with-boost-libdir=$PREFIX/lib \
    || (cat config.log; false)

make
make check
make install
