#!/bin/sh

./configure --prefix=$PREFIX \
            --with-png \
            --with-jpeg \
            --with-tiff \
            --with-freetype \
            --with-zlib \
            --without-vpx \
            --without-xpm

make
make install
