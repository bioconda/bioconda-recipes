#!/bin/sh

PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH \
  ./configure \
     --with-mlapack=$PREFIX --prefix=$PREFIX && \
make ${CPUS_COUNT} && \
make install
