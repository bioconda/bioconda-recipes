#!/bin/bash
set -eu -o pipefail

PKG_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PKG_HOME
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp -r  PIPmiR src README $PKG_HOME/.
chmod +x $PKG_HOME/PIPmiR
ln -s $PKG_HOME/PIPmiR $PREFIX/bin/PIPmiR
