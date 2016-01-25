#!/bin/bash

pushd $SRC_DIR

sed -i 's/AM_CXXFLAGS = -g -O3/AM_CXXFLAGS = -g -O3 -Wno-maybe-uninitialized/' Makefile.am
autoreconf -i -I /usr/share/aclocal
./configure --prefix=$PREFIX
make
make install
