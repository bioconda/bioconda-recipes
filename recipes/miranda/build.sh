#!/bin/sh
set -e
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"

./configure --prefix=$PREFIX
make
make check
make install
