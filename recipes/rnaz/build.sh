#!/bin/bash
./configure CFLAGS="-std=gnu89 -g -O2" --prefix=$PREFIX --datadir=$PREFIX/share --libdir=$PREFIX/lib
make
make install
