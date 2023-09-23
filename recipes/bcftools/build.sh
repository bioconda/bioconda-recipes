#!/bin/sh
set -ex
./configure --prefix=$PREFIX --with-htslib=system --enable-libgsl
make all GSL_LIBS=-lgsl
make install
ldd -r $PREFIX/bin/bcftools |grep "libgsl.so.27"
