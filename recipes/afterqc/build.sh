#!/bin/bash
set -eu

target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# Copy executables & modules
cp *.py $target

chmod -R a+rx $target/
ln -s $target/* $PREFIX/bin
