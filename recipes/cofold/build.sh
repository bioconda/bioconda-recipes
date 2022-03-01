#!/bin/sh
CXXFLAGS="${CXXFLAGS} -std=gnu++14 -fcommon"
# ViennaRNA does not support Python 3 yet.
./configure --prefix=$PREFIX --without-perl -q
make clean
make
make install
