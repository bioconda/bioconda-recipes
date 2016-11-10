#!/bin/bash

CPPFLAGS=-Wno-error=unused-function \
./configure --prefix=$PREFIX \
            --with-png \
            --with-jpeg \
            --with-tiff \
            --with-freetype \
            --with-zlib \
            --without-xpm \
            --without-x \
            --without-fontconfig

make
make install
