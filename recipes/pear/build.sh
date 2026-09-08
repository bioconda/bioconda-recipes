#!/bin/bash
set -xeuo pipefail
autoreconf -i
./configure --prefix=$PREFIX LDFLAGS="$(pkg-config --libs zlib)" CFLAGS="$(pkg-config --cflags zlib)"
make
make install
ln -s $PREFIX/bin/pear $PREFIX/bin/pearRM
