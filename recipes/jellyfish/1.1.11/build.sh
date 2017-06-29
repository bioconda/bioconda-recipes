#!/bin/bash

pushd $SRC_DIR

sed -i.bak 's/AM_CXXFLAGS = -g -O3/AM_CXXFLAGS = -g -O3/' Makefile.am
autoreconf -i -I /usr/share/aclocal
./configure --prefix=$PREFIX
make
make install
