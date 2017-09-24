#!/bin/env bash
export INCLUDE_PATH="${PREFIX}/include"
export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

./configure --prefix=$PREFIX \
    --with-gocr-include=$PREFIX/include/gocr/ \
    --with-gocr-lib=$PREFIX/lib/ \
    --with-openbabel-include=$PREFIX/include/openbabel-2.0/ \
    --with-openbabel-lib=$PREFIX/lib \
    --with-graphicsmagick-include=$PREFIX/include/ \
    --with-graphicsmagick-lib=$PREFIX/lib/
make
make install
