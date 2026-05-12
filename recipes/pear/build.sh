#!/bin/bash
set -xeuo pipefail
autoreconf
automake --add-missing
./configure --prefix=$PREFIX LDFLAGS="$(pkg-config --libs zlib)" CFLAGS="$(pkg-config --cflags zlib)"
make
make install
ln -s $PREFIX/bin/pear $PREFIX/bin/pearRM
