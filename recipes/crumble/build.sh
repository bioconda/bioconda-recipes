#!/bin/sh

aclocal
autoconf
automake
./configure --prefix=${PREFIX}
make
make install
