#!/bin/bash
set -eu -o pipefail

PKG_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PKG_HOME
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp -r  PARalyzer README.txt src $PKG_HOME/.
chmod +x $PKG_HOME/PARalyzer
ln -s $PKG_HOME/PARalyzer $PREFIX/bin/PARalyzer
