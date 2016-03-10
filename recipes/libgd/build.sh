#!/bin/sh

./configure --prefix=$PREFIX \
            --with-png \
            --with-jpeg \
            --with-tiff \
            --with-freetype \
            --with-zlib \
            --without-vpx \
            --without-xpm \
            --without-x \
            --without-fontconfig

make
make install
