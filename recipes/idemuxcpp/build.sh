#!/bin/sh

./configure --enable-tests --prefix="${PREFIX}" LIBS="-lrt"
make
make install
make check
