#!/bin/sh
./configure --prefix=$PREFIX PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ CXXFLAGS="-I$PREFIX/include"
make install

for p in \
    locarna \
    locarna_p \
    exparna_p \
    locarnap_fit \
    locarna_rnafold_pp \
    ribosum2cc \
    sparse \
; do
  strip $PREFIX/bin/$p
done
