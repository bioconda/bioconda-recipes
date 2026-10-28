#!/bin/sh
cp -rf $BUILD_PREFIX/share/gnuconfig/config.* .

./configure  --enable-threads --prefix=$PREFIX
make
make install --always-make
