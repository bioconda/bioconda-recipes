#!/bin/env bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

./configure --with-tclap-include=$PREFIX/include/ \
    --with-potrace-include=$PREFIX/include/ \
    --with-potrace-lib=$PREFIX/lib/ \
    --with-gocr-include=$PREFIX/include/gocr/ \
    --with-gocr-lib=$PREFIX/lib/ \
    --with-ocrad-include=$PREFIX/include/ \
    --with-ocrad-lib=$PREFIX/lib/ \
    --with-openbabel-include=$PREFIX/include/openbabel-2.0/ \
    --with-openbabel-lib=$PREFIX/lib \
    --with-graphicsmagick-lib=$PREFIX/lib/ \
    --with-graphicsmagick-include=$PREFIX/include/ \
    --prefix=$PREFIX
make all install
