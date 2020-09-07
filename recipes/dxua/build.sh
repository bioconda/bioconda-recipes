#!/bin/bash

set -eu -o pipefail

cd $SRC_DIR/

PKG_BINARY=ua
BINARY_HOME=$PREFIX/bin
PKG_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

cd $SRC_DIR

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $PKG_HOME
cp -R $SRC_DIR/* $PKG_HOME/
cd $PKG_HOME && chmod +x $PKG_BINARY
cd $BINARY_HOME && ln -s $PKG_HOME/$PKG_BINARY $PKG_NAME
