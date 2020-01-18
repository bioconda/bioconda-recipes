#!/bin/sh
./configure --prefix=$PREFIX --with-htslib=system --enable-libgsl
make all
make install
