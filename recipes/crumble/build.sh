#!/bin/sh
set -ex

aclocal
autoconf
./configure --prefix=${PREFIX}
make
make install
