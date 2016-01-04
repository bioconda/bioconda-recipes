#!/bin/sh

# the executable is not installed in $PREFIX though
# make install prefix=$PREFIX

make
mkdir -p $PREFIX/bin
cp $PKG_NAME $PREFIX/bin
