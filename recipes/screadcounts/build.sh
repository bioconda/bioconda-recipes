#!/bin/bash

set -eu

# TARGET=$BUILD_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
TARGET=$BUILD_PREFIX/share/$PKG_NAME
mkdir -p $TARGET
mkdir -p $BUILD_PREFIX/bin
cp -r $SRC_DIR/{bin,src,docs,data} $TARGET
chmod -R a+r $TARGET/
chmod -R a+x $TARGET/bin/
ln -s $TARGET/bin/* $BUILD_PREFIX/bin
