#!/bin/sh

set -e -u -x

./configure --prefix=$PREFIX --enable-threads
make
make install
