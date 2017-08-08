#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

cp *.py $target

chmod -R 0755 $target
ln -s $target/* $PREFIX/bin