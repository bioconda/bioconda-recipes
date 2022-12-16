#!/bin/sh
set -ex

autoreconf -i
./configure --prefix=${PREFIX}
make
make install
