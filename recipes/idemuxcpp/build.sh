#!/bin/sh

./configure --enable-tests --prefix="${PREFIX}"
make
make install
make check
