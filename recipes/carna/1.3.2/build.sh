#!/bin/sh
./configure --prefix=$PREFIX --disable-gist GECODE_HOME=$prefix PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

make -j${CPU_COUNT}
make install
