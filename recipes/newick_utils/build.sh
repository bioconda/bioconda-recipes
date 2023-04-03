#!/bin/bash
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
autoreconf -fi
./configure --prefix=$PREFIX --without-guile --without-lua --with-libxml
make
make install

