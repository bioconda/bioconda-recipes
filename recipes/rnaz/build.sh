#!/bin/bash
./configure CFLAGS="-std=gnu89 -g -O2" --prefix=$PREFIX --datadir=$PREFIX/share
make
make install
