#!/bin/bash

set -e

macse=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $macse
cp -r $SRC_DIR/* $macse
chmod +x $macse/macse_v2.03.jar
mkdir -p $PREFIX/bin
ln -s $macse/macse_v2.03.jar $PREFIX/bin/macse