#!/bin/sh

./configure --prefix=$PREFIX \
            --with-png \
            --with-jpeg \
            --with-tiff \
            --with-freetype \
            --with-zlib

make
make install
