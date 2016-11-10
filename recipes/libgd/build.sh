#!/bin/bash

# ensure script fail on command fail
set -e -o pipefail

# remove -Werror from build
sed -i.bak1 "s|-Werror||g" ./configure
# run configure
./configure --prefix=$PREFIX \
            --with-png \
            --with-jpeg \
            --with-tiff \
            --with-freetype \
            --with-zlib \
            --without-xpm \
            --without-x \
            --without-fontconfig
# compile
make
# install
make install
