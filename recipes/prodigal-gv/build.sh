#!/bin/sh

set -xe

# the executable is not installed in $PREFIX though
# make install prefix=$PREFIX

make -j"${CPU_COUNT}" CC=$CC
mkdir -p $PREFIX/bin
cp $PKG_NAME $PREFIX/bin
