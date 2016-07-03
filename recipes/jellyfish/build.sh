#!/bin/bash

pushd $SRC_DIR

autoreconf -i -I $PREFIX/share/aclocal
./configure --prefix=$PREFIX
make
make install
