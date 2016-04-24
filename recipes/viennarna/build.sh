#!/bin/sh
# ViennaRNA does not support Python 3 yet.
./configure --prefix=$PREFIX --without-python --without-ruby --disable-openmp --without-forester
make install
