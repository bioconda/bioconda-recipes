#!/bin/bash

pushd $SRC_DIR

autoreconf -i -I /usr/share/aclocal
./configure --prefix=$PREFIX
make
make install
