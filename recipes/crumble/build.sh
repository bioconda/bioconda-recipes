#!/bin/sh
set -ex

aclocal
automake --force-missing --add-missing
autoconf
./configure --prefix=${PREFIX}
make
make install
