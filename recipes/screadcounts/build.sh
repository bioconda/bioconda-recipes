#!/bin/bash

set -eu

TARGET=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $TARGET
mkdir -p $PREFIX/bin
cp -r bin src docs data $TARGET
chmod -R a+r $TARGET/
chmod -R a+x $TARGET/bin/
ln -s $TARGET/bin/* $PREFIX/bin
