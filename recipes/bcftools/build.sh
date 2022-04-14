#!/bin/sh
./configure --prefix=$PREFIX --with-htslib=system --enable-libgsl
make all GSL_LIBS=-lgsl
make install
