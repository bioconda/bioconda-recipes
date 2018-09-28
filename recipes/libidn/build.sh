#!/bin/bash

set -o pipefail
./configure --prefix=$PREFIX \
    --with-pic --enable-static --disable-shared \
    --disable-java \
    --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
    --without-libiconv-prefix \
    --without-libintl-prefix \
    --without-libpth-prefix \
    --without-lispdir \
    --without-packager \
    2>&1 | tee configure.log
make
make install
#rm -rf "${PREFIX}/share/info" "${PREFIX}/share/man"
