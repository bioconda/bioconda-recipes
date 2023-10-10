#!/bin/sh

# the executable is not installed in $PREFIX though
# make install prefix=$PREFIX

make CC=$CC
mkdir -p $PREFIX/bin
cp $PKG_NAME $PREFIX/bin
