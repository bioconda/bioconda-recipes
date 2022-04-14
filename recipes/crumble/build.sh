#!/bin/sh
set -ex
autoconf
./configure --prefix=${PREFIX}
make
make install
