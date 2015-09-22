#!/bin/sh
# ViennaRNA does not support Python 3 yet.
./configure --prefix=$PREFIX --without-python --without-ruby
make -j -- install
strip $PREFIX/bin/*
