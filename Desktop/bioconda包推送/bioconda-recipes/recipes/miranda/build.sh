#!/bin/sh
set -e
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"

# use newer config.guess and config.sub that support linux-aarch64
cp -rf $BUILD_PREFIX/share/gnuconfig/config.* .
./configure --prefix=$PREFIX
make
make check
make install
