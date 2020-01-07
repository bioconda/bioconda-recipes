#!/bin/bash
# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

./configure --prefix=$PREFIX --with-gsl-prefix=$PREFIX #--disable-gsltest
make
make install
